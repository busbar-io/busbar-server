module NamespaceService
  extend SingleForwardable

  def_delegator Namespaces::Upserter, :call, :upsert
  def_delegator Namespaces::Destroyer, :call, :destroy
end
