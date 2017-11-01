class App
  include Mongoid::Document
  include Mongoid::Timestamps

  field :_id,             type: String
  field :buildpack_id,    type: String
  field :repository,      type: String
  field :default_branch,  type: String,  default: 'master'
  field :default_node_id, type: String,  default: '1x.standard'

  validates :_id,          presence: true, uniqueness: true
  validates :buildpack_id, inclusion: { in: %w(ruby java node custom) }
  validates :repository,   presence: true

  has_many :environments,  dependent: :destroy

  def environment_names
    environments.pluck(:name)
  end
end
