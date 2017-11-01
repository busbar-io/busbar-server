module Deployments
  class Creator
    include Serviceable

    def call(environment, data = {}, options = {})
      @environment = environment
      @data        = data.with_indifferent_access
      @options     = options.with_indifferent_access
      return deployment unless environment.present? && deployment.save

      process
      deployment
    end

    private

    attr_reader :environment, :data, :options

    def deployment
      return @deployment if defined?(@deployment)
      @deployment = DeploymentFactory.call(environment, data, options)
    end

    def process
      if options[:sync] == true
        DeploymentService.process(deployment, options)
      else
        DeploymentProcessing.perform_async(deployment.id.to_s, options)
      end
    end
  end
end
