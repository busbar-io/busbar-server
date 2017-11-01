class DeploymentFactory
  include Serviceable

  def call(environment, data = {}, options = {})
    @environment  = environment
    @data         = data.with_indifferent_access
    @options      = options.with_indifferent_access

    Deployment.new(data).tap do |d|
      d.environment = environment
      d.settings    = environment.settings

      d.buildpack_id = environment.buildpack_id if @data[:buildpack_id].nil?
      d.branch = environment.default_branch if @data[:branch].nil?

      if bypass_build?
        d.build_id = effective_build_id
        d.state    = 'built'
      else
        d.build_id = nil
      end
    end
  end

  private

  attr_reader :environment, :data, :options

  def effective_build_id
    @effective_build_id ||= data.fetch('build_id', environment&.latest_built_build&.id)
  end

  def bypass_build?
    !options['build'] && effective_build_id.present?
  end
end
