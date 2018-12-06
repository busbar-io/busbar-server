class Node
  include Virtus.model

  class << self
    attr_writer :collection

    def find(id)
      data = @collection.find { |e| e['id'] == id }
      return unless data.present?

      new(data)
    end
  end

  attribute :id,             String
  attribute :cpu,            String
  attribute :guaranteed_cpu, String
  attribute :memory,         String
  attribute :selector,       String, :default => Configurations.apps.node_selector
end
