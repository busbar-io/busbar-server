module Dns
  class ZoneCreator
    include Serviceable

    IMPLEMENTED_PROVIDERS = %w(dnsimple route53).freeze

    DnsCreationError = Class.new(StandardError)

    def call(provider, domain, name, value)
      @provider = provider
      @domain = domain
      @name = name
      @value = value

      unless IMPLEMENTED_PROVIDERS.include?(@provider)
        raise(DnsCreationError, name: @name, message: "Provider #{@provider} not implemented")
      end

      if @provider == 'dnsimple'
        dnsimple_create
      elsif @provider == 'route53'
        route53_create
      end
    end

    private

    attr_reader :name, :value, :account_id

    def dnsimple_create
      @account_id = Configurations.dnsimple.account_id
      begin
        if dnsimple_record.nil?
          attributes = { name: @name,
                         type: 'CNAME',
                         content: @value }
          DnsimpleClient.zones.create_record(@account_id,
                                             @domain,
                                             attributes)
        else
          DnsimpleClient.zones.update_record(@account_id,
                                             @domain,
                                             dnsimple_record.id,
                                             content: @value)
        end
      rescue StandardError => e
        raise(DnsCreationError, name: @name, message: e.message)
      end
      true
    end

    def route53_create
      begin
        Route53.change_resource_record_sets(route53_manifest)
      rescue StandardError => e
        raise(DnsCreationError, name: @name, message: e.message)
      end
      true
    end

    def dnsimple_record
      return @dnsimple_record if defined?(@dnsimple_record)
      query = DnsimpleClient.zones.list_records(@account_id,
                                                @domain,
                                                query: { name: @name })
      @dnsimple_record ||= query.data.first
    end

    def route53_record_name
      "#{@name}.#{@domain}"
    end

    def route53_manifest
      record_set = { name: route53_record_name,
                     type: 'CNAME',
                     ttl: 600,
                     resource_records: [{ value: @value }] }
      changes = { changes: [{ action: 'UPSERT', resource_record_set: record_set }] }
      { hosted_zone_id: route53_zone.id,
        change_batch: changes }
    end

    def route53_zone(name = "#{@domain}.")
      return @route53_zone if defined?(@route53_zone)
      @route53_zone = Route53.list_hosted_zones[:hosted_zones].find { |zone| zone.name == name }
    end
  end
end
