module DatabaseService
  extend SingleForwardable

  def_delegator Databases::Creator, :call, :create
  def_delegator Databases::Destroyer, :call, :destroy
  def_delegator Databases::Processor, :call, :process
  def_delegator Databases::VolumeCreator, :call, :create_volume
  def_delegator Databases::ReplicationControllerCreator, :call, :create_replication_controller
  def_delegator Databases::ServiceCreator, :call, :create_service
end
