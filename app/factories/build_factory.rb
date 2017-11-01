class BuildFactory
  include Serviceable

  def call(environment, data = {})
    @environment = environment
    @data        = data.with_indifferent_access
    return build unless environment.present?

    inject_boilerplate_data
    build
  end

  private

  attr_reader :environment, :data

  def build
    @build ||= Build.new(data)
  end

  def inject_boilerplate_data
    build.tap do |b|
      b.environment = environment
      b.repository  = environment.repository

      b.log = Log.new(content: '')

      b.branch ||= (environment.default_branch || 'master')
      b.buildpack_id ||= environment.buildpack_id
    end
  end
end
