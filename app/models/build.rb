class Build
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM

  STATES = %w(pending
              building
              broken
              ready).freeze

  field :state,        type: String, default: 'pending'
  field :buildpack_id, type: String
  field :repository,   type: String
  field :branch,       type: String
  field :tag,          type: String
  field :commit,       type: String
  field :commands,     type: Hash
  field :built_at,     type: Time

  belongs_to :environment, index: true
  has_one :log, dependent: :destroy

  index(created_at: -1)
  index(updated_at: -1)
  index(built_at: -1)
  index(state: 1)

  validates :environment_id, presence: true
  validates :buildpack_id,   presence: true
  validates :repository,     presence: true
  validates :branch,         presence: true
  validates :state,          presence: true, inclusion: STATES

  scope :ready, -> { where(state: 'ready') }

  delegate :app_id, to: :environment

  aasm column: 'state' do
    state :pending
    state :building
    state :ready
    state :broken

    event :start do
      transitions from: :pending, to: :building
    end

    event :finish do
      transitions from:  %i(pending building),
                  to:    :ready,
                  after: -> { update_attributes(built_at: Time.zone.now) }
    end

    event :fail do
      transitions from: %i(pending building), to: :broken
    end
  end

  def path(base_path = Configurations.slug_builder.base_path)
    [base_path, id.to_s].join('/')
  end

  def image_url(registry_url = Configurations.docker.private_registry_url)
    [registry_url, image_tag].join('/')
  end

  def image_tag
    @image_tag ||= "#{environment.id}:latest"
  end

  def buildpack
    @buildpack ||= BuildpackService.resolve(buildpack_id)
  end

  def log_content
    return log.content unless log.nil?
    ''
  end
end
