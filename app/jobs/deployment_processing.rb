class DeploymentProcessing
  include Sidekiq::Worker

  DeploymentNotFound = Class.new(StandardError)

  def perform(deployment_id, options = {})
    @deployment_id = deployment_id

    raise(DeploymentNotFound, deployment_id: deployment_id) unless deployment.present?

    begin
      LockService.synchronize(data) do
        DeploymentService.process(deployment, options.with_indifferent_access)
      end
    rescue
      deployment.fail!
    end
  end

  private

  attr_reader :deployment_id

  def data
    { environment_id: deployment.environment_id }
  end

  def deployment
    return @deployment if defined?(@deployment)
    @deployment = Deployment.find(deployment_id)
  rescue Mongoid::Errors::DocumentNotFound
    @deployment = nil
  end
end
