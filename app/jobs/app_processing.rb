class AppProcessing
  include Sidekiq::Worker

  def perform(data, options = {}, environment_params = {})
    @data = data.with_indifferent_access
    @options = options.with_indifferent_access
    @environment_params = environment_params.with_indifferent_access

    @options = @environment_params[:environment] if @environment_params[:environment].present?

    LockService.synchronize(@data) do
      AppService.process(@data, @options)
    end
  end
end
