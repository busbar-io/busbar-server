module DnsService
  extend SingleForwardable

  def_delegator Dns::ZoneCreator, :call, :create_zone
end
