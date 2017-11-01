class Database
  include Mongoid::Document
  include Mongoid::Timestamps

  SUPPORTED_DBS = %w(mongo redis).freeze
  DB_VERSIONS = { mongo: '3.2', redis: '3.0' }.with_indifferent_access
  DB_PORTS = { mongo: 27_017, redis: 6379 }.with_indifferent_access
  DB_PATHS = { mongo: '/data/db', redis: '/data' }.with_indifferent_access

  field :_id,       type: String
  field :type,      type: String
  field :namespace, type: String
  field :size,      type: Integer, default: 1

  validates :_id, presence: true, uniqueness: true
  validates :type, presence: true
  validates :namespace, presence: true

  validates_format_of :id, without: /\W^(-)+|_+|\.+|[A-Z]/
  validates_inclusion_of :type, in: SUPPORTED_DBS

  alias name id

  def image
    "#{type}:#{DB_VERSIONS.fetch(type, '1.0')}"
  end

  def role
    "#{type}-single"
  end

  def port
    DB_PORTS[type]
  end

  def path
    DB_PATHS[type]
  end

  def url
    "#{type}://#{name}"
  end
end
