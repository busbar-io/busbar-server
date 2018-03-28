module LocalInterfaceService
  extend SingleForwardable

  def_delegator LocalInterfaces::Creator,   :call, :create
  def_delegator LocalInterfaces::Destroyer, :call, :destroy
end
