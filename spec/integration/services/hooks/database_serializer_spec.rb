require 'rails_helper'

RSpec.describe Hooks::DatabaseSerializer do
  subject { described_class.call(database) }

  let(:database) do
    instance_double(
      Database,
      id: 'some_db',
      size: 1,
      type: 'mongo',
      namespace: 'develop',
      class: double(:class, name: 'Database')
    )
  end

  it 'serializes the database' do
    expect(subject).to match(
      database_id: 'some_db',
      database_size: 1,
      database_type: 'mongo',
      database_namespace: 'develop'
    )
  end
end
