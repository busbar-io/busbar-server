class Setting
  include Virtus.model
  include ActiveModel::Validations

  attribute :key, String
  attribute :value, String

  validates :key,   presence: true
  validates :value, presence: true
end
