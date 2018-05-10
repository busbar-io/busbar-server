module MinikubeInterfaceService
  extend SingleForwardable

  def_delegator MinikubeInterfaces::Creator,   :call, :create
  def_delegator MinikubeInterfaces::Destroyer, :call, :destroy
end
