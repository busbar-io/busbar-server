class AppDestroyProcessing
  include Sidekiq::Worker

  AppNotFound = Class.new(StandardError)

  def perform(app_id)
    @app_id = app_id

    raise(AppNotFound, app_id: app_id) unless app.present?

    LockService.synchronize(app_id: app.id) do
      app.environments.each do |env|
        EnvironmentService.destroy(env)
      end

      app.destroy
    end

    HookService.call(resource: app, action: 'destroy', value: 'success')
  end

  private

  attr_reader :app_id

  def app
    @app ||= App.find(app_id)
  rescue Mongoid::Errors::DocumentNotFound, Mongoid::Errors::InvalidFind
    @app = nil
  end
end
