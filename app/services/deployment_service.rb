module DeploymentService
  extend SingleForwardable

  def_delegator Deployments::Creator,   :call, :create
  def_delegator Deployments::Processor, :call, :process
end
