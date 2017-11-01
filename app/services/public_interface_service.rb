module PublicInterfaceService
  extend SingleForwardable

  def_delegator PublicInterfaces::Creator,   :call, :create
  def_delegator PublicInterfaces::Destroyer, :call, :destroy
end
