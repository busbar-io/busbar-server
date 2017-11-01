class Component
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM

  STATES = %w(new installed uninstalled).freeze

  attr_writer :settings

  field :type,      type: String
  field :command,   type: String
  field :node_id,   type: String,  default: '1x.standard'
  field :scale,     type: Integer, default: 0
  field :state,     type: String,  default: 'new'
  field :image_url, type: String

  belongs_to :environment, index: true

  validates :environment_id,  presence: true
  validates :node_id,         presence: true
  validates :command,         presence: true
  validates :type,            presence: true, uniqueness: { scope: :environment_id }
  validates :scale,           presence: true
  validates :state,           presence: true, inclusion: STATES
  validates :image_url,       presence: true

  index({ environment_id: 1, type: 1 }, unique: true)

  delegate :name, to: :environment, prefix: true

  aasm column: 'state' do
    state :new
    state :installed
    state :uninstalled

    event :install do
      transitions from: %i(new uninstalled), to: :installed
    end

    event :uninstall do
      transitions from: %i(installed), to: :uninstalled
    end
  end

  def name
    [app_id, environment_id, type].join('-')
  end

  def app_id
    environment.app_id
  end

  def node
    @node ||= Node.find(node_id)
  end

  def settings
    return if environment.blank?
    @settings ||= environment&.latest_deployment&.settings
  end

  def manifest
    @manifest ||= Manifest.new(component: self, settings: settings)
  end

  def manifest_file
    @manifest_file ||= Tempfile.new(['component', id].join('-')).tap do |f|
      IO.write(f.path, manifest.render.to_json)
    end
  end

  def selector(prefix = Configurations.kubernetes.label_prefix)
    "#{prefix}/environment=#{environment_id},#{prefix}/component=#{type}"
  end

  def namespace
    environment.namespace
  end

  def environment_name
    environment.name
  end

  def log
    environment.log
  end
end
