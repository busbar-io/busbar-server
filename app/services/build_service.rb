module BuildService
  extend SingleForwardable

  def_delegator Builds::CollectionFinder, :call, :where
  def_delegator Builds::Creator,          :call, :create
  def_delegator Builds::Compiler,         :call, :compile
end
