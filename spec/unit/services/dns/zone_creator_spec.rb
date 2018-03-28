require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Dns::ZoneCreator do
  describe '.call' do
    before(:all) { VCR.turn_off! }
    after(:all) { VCR.turn_on! }

    let(:provider)    { 'not_implemented' }
    let(:name)        { 'test' }
    let(:value)       { 'test.some.url' }
    let(:domain) { 'example.com' }
    subject { described_class.call(provider, domain, name, value) }

    it 'check not_implemented provider' do
      expect { subject }.to raise_error(Dns::ZoneCreator::DnsCreationError)
    end

    context 'dnsimple' do
      let(:provider) { 'dnsimple' }
      let(:zone_id)  { 1234 }
      let(:list_records_exist) do
        { data: [{ id:        zone_id,
                   zone_id:   domain,
                   parent_id: nil,
                   name:      'does_not_really_matter',
                   content:   'whatever',
                   ttl:       3600,
                   priority:  nil,
                   type:      'CNAME' }],
          pagination: { current_page:  1,
                        per_page:      1,
                        total_entries: 1,
                        total_pages:   1 } }
      end
      let(:list_records_empty) do
        { data: [],
          pagination: {
            current_page:  1,
            per_page:      1,
            total_entries: 1,
            total_pages:   1
          } }
      end

      context 'when the record already exists' do
        before do
          stub_request(:get, "https://api.dnsimple.com/v2/0/zones/#{domain}/records?name=#{name}")
            .with(headers: { Accept: 'application/json', 'User-Agent': 'dnsimple-ruby/4.4.0' })
            .to_return(status:  200, body: list_records_exist.to_json, headers: {})
          allow(DnsimpleClient.zones).to receive(:update_record)
        end
        it 'updates the record' do
          expect(DnsimpleClient.zones).to receive(:update_record)
            .with(0, domain, zone_id, content: value)
          subject
        end

        context 'when an error happens during the record update' do
          before do
            allow(DnsimpleClient.zones).to receive(:update_record)
              .and_raise(StandardError.new('some error'))
          end

          it 'raises DnsCreationError' do
            expect { subject }.to raise_error(Dns::ZoneCreator::DnsCreationError)
          end
        end
      end

      context 'when the record does not exists' do
        before do
          stub_request(:get, "https://api.dnsimple.com/v2/0/zones/#{domain}/records?name=#{name}")
            .with(headers: { Accept: 'application/json', 'User-Agent': 'dnsimple-ruby/4.4.0' })
            .to_return(status:  200, body: list_records_empty.to_json, headers: {})
          allow(DnsimpleClient.zones).to receive(:create_record)
        end
        it 'creates the record' do
          expect(DnsimpleClient.zones).to receive(:create_record)
            .with(0, domain, content: value, type: 'CNAME', name: name)
          subject
        end

        context 'when an error happens during the record creation' do
          before do
            allow(DnsimpleClient.zones).to receive(:create_record)
              .and_raise(StandardError.new('some error'))
          end

          it 'raises DnsCreationError' do
            expect { subject }.to raise_error(Dns::ZoneCreator::DnsCreationError)
          end
        end
      end
    end

    context 'route53' do
      let(:provider) { 'route53' }
      let(:hosted_zones) { { name: "#{domain}.", id: name  } }
      let(:aws_desc) do
        {
          hosted_zone_id: name,
          change_batch: {
            changes: [
              action: 'UPSERT',
              resource_record_set: {
                name: "#{name}.#{domain}",
                type: 'CNAME',
                ttl: 600,
                resource_records: [{ value: value }]
              }
            ]
          }
        }
      end

      before do
        allow(Route53).to receive(:list_hosted_zones)
          .and_return(hosted_zones: [OpenStruct.new(hosted_zones)])
      end

      it 'creates a DNS Route53 DNS' do
        expect(Route53).to receive(:change_resource_record_sets).with(aws_desc)
        subject
      end

      context 'when an error happens on the DNS record creation' do
        before do
          allow(Route53).to receive(:list_hosted_zones)
            .and_raise(StandardError.new('some error'))
        end

        it 'raises DnsCreationError' do
          expect { subject }.to raise_error(Dns::ZoneCreator::DnsCreationError)
        end
      end
    end
  end
end
