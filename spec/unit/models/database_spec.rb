require 'rails_helper'

RSpec.describe Database, type: :model do
  subject do
    Database.new(
      _id: 'mydb',
      type: db_type,
      namespace: 'staging'
    )
  end

  let(:db_type) { 'mongo' }

  it { is_expected.to be_valid }

  it "isn't valid without an id" do
    subject.id = nil
    expect(subject).not_to be_valid
  end

  it "isn't valid without a type" do
    subject.type = nil
    expect(subject).not_to be_valid
  end

  it "isn't valid without a namespace" do
    subject.namespace = nil
    expect(subject).not_to be_valid
  end

  it "isn't valid with an id that contains uppercase characters" do
    subject.id = 'MyDb'

    expect(subject).not_to be_valid
  end

  it "isn't valid with an id that contains underscores" do
    subject.id = 'my_db'

    expect(subject).not_to be_valid
  end

  it "isn't valid with an id that contains dots" do
    subject.id = 'my.db'

    expect(subject).not_to be_valid
  end

  it 'has the name equal to its id' do
    expect(subject.name).to eq('mydb')
  end

  context 'when the db type is mongo' do
    it 'uses the appropriate image version' do
      expect(subject.image).to eq('mongo:3.2')
    end

    it 'uses the appropriate role' do
      expect(subject.role).to eq('mongo-single')
    end

    it 'uses port 27017' do
      expect(subject.port).to eq(27_017)
    end

    it 'uses a path /data/db' do
      expect(subject.path).to eq('/data/db')
    end

    it 'has the appropriate url' do
      expect(subject.url).to eq('mongo://mydb')
    end
  end

  context 'when the db type is redis' do
    let(:db_type) { 'redis' }

    it 'uses the appropriate image version' do
      expect(subject.image).to eq('redis:3.0')
    end

    it 'uses the appropriate role' do
      expect(subject.role).to eq('redis-single')
    end

    it 'uses port 6379' do
      expect(subject.port).to eq(6379)
    end

    it 'uses a path /data' do
      expect(subject.path).to eq('/data')
    end

    it 'has the appropriate url' do
      expect(subject.url).to eq('redis://mydb')
    end
  end
end
