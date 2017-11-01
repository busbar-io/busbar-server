class EnvironmentCloneProcessing
  include Sidekiq::Worker

  EnvironmentNotFound = Class.new(StandardError)

  def perform(environment_id, clone_name)
    @environment_id = environment_id

    LockService.synchronize(environment_id: environment.id) do
      EnvironmentService.clone(environment, clone_name)
    end
  end

  private

  attr_reader :environment_id

  def environment
    @environment ||= Environment.find(environment_id)
  rescue Mongoid::Errors::DocumentNotFound
    raise(EnvironmentNotFound, environment_id: @environment_id)
  end
end
