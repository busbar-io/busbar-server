module Settings
  class BulkController < ApplicationController
    before_action :load_environment

    def update
      @settings = SettingService.bulk_upsert(@environment, settings_params, deployment_params)

      respond_to do |format|
        if @settings.all?(&:valid?)
          format.json { render status: :ok }
        else
          format.json { render status: :unprocessable_entity }
        end
      end
    end

    private

    def settings_params
      params[:settings]
    end

    def deployment_params
      params.permit(:deploy).tap do |whitelisted|
        whitelisted[:deploy] = true if params[:deploy].nil?
      end
    end

    def load_environment
      @environment = Environment.find_by(name: params[:environment_name], app_id: params[:app_id])
    end
  end
end
