class EnvironmentProcessing
  include Sidekiq::Worker

  EnvironmentNotFound = Class.new(StandardError)

  def perform(environment_id)
    @environment_id = environment_id

    load_environment

    LockService.synchronize(environment_id: environment_id) do
      EnvironmentService.process(environment)
    end
  end

  private

  attr_reader :environment_id, :environment

  def load_environment
    @environment ||= Environment.find(environment_id)
  rescue Mongoid::Errors::DocumentNotFound, Mongoid::Errors::InvalidFind
    raise(EnvironmentNotFound, environment_id: environment_id)
  end
end
