module PrivateInterfaceService
  extend SingleForwardable

  def_delegator PrivateInterfaces::Creator,   :call, :create
  def_delegator PrivateInterfaces::Destroyer, :call, :destroy
end
