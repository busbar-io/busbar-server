class Deployment
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM

  STATES = %w(pending
              building
              built
              launching
              done
              failed).freeze

  field :settings,     type: Hash,   default: {}
  field :buildpack_id, type: String
  field :branch,       type: String
  field :state,        type: String, default: 'pending'
  field :deployed_at,  type: Time

  belongs_to :environment,   index: true
  belongs_to :build, index: true

  index(created_at: -1)
  index(updated_at: -1)
  index(deployed_at: -1)
  index(state: 1)

  validates :environment_id, presence: true
  validates :state,          presence: true, inclusion: STATES

  scope :done, -> { where(state: 'done') }

  aasm column: 'state' do
    state :pending
    state :building
    state :built
    state :launching
    state :done
    state :failed

    event :start_building do
      transitions from: :pending, to: :building do
        guard do
          build_id.blank?
        end
      end
    end

    event :finish_building do
      transitions from: :building, to: :built
    end

    event :launch do
      transitions from: %i(pending built), to: :launching do
        guard do
          build_id.present?
        end
      end
    end

    event :finish do
      transitions from: %i(launching),
                  to:    :done,
                  after: -> { update_attributes(deployed_at: Time.zone.now) }
    end

    event :fail do
      transitions from: %i(pending building launching), to: :failed
    end
  end

  def tag
    return build.tag if build.present?
    'pending'
  end

  def commit
    return build.commit if build.present?
    'pending'
  end

  def log
    build.log
  end

  def environment_name
    environment.name
  end

  def app_id
    environment.app_id
  end
end
