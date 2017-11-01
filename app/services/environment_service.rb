module EnvironmentService
  extend SingleForwardable

  def_delegator Environments::Creator, :call, :create
  def_delegator Environments::Destroyer, :call, :destroy
  def_delegator Environments::ComponentsDestroyer, :call, :destroy_components
  def_delegator Environments::Processor, :call, :process
  def_delegator Environments::Cloner, :call, :clone
end
