class Environment
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM

  STATES = %w(new processing available).freeze

  field :_id,             type: String
  field :buildpack_id,    type: String
  field :name,            type: String,  default: Configurations.environments.default_name
  field :state,           type: String,  default: 'new'
  field :public,          type: Boolean, default: false
  field :settings,        type: Hash,    default: {}
  field :default_branch,  type: String,  default: 'master'
  field :default_node_id, type: String,  default: '1x.standard'

  belongs_to :app,   index: true

  has_many :builds,      dependent: :destroy
  has_many :deployments, dependent: :destroy
  has_many :components,  dependent: :destroy

  validates :app_id,       presence: true
  validates :_id,          presence: true, uniqueness: true

  validates :name,         presence: true

  # this allows only letters, numbers '-' and '.'
  validates_format_of :name, without: /\W^(\.|-)+|_+/
  validates :name, uniqueness: { scope: :app_id }

  validates :state,        presence: true, inclusion: STATES
  validates :buildpack_id, presence: true

  alias namespace name

  aasm column: 'state' do
    state :new
    state :processing
    state :available

    event :checkout do
      transitions from: %i(new), to: :processing
    end

    event :finish do
      transitions from: %i(processing), to: :available
    end
  end

  def latest_built_build
    builds.desc(:built_at).ready.first
  end

  def latest_build
    builds.desc(:created_at).first
  end

  def latest_deployment
    deployments.desc(:deployed_at).done.first
  end

  def repository
    app.repository
  end

  def default_node_id
    super || app.default_node_id
  end

  def log
    latest_build.log
  end
end
