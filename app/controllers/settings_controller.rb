class SettingsController < ApplicationController
  before_action :load_environment
  before_action :load_setting, only: %i(show destroy)

  def index
    @settings = SettingService.where(@environment)

    respond_to do |format|
      format.json { render status: :ok }
    end
  end

  def show
    return head :not_found unless @setting.present?

    respond_to do |format|
      format.json { render status: :ok }
    end
  end

  def update
    @setting = SettingService.upsert(@environment, setting_params, deployment_params)

    respond_to do |format|
      if @setting.valid?
        format.json { render status: :ok }
      else
        format.json { render status: :unprocessable_entity }
      end
    end
  end

  def destroy
    return head :not_found unless @setting.present?

    respond_to do |format|
      if SettingService.destroy(@environment, @setting)
        format.json { head :no_content }
      else
        format.json { render status: :unprocessable_entity }
      end
    end
  end

  private

  def setting_params
    params.permit(:key, :value).tap do |whitelisted|
      whitelisted[:key] = params[:id]
    end
  end

  def deployment_params
    params.permit(:deploy).tap do |whitelisted|
      whitelisted[:deploy] = true if params[:deploy].nil?
    end
  end

  def load_environment
    @environment = Environment.find_by(name: params[:environment_name], app_id: params[:app_id])
  end

  def load_setting
    @setting = SettingService.find(@environment, setting_params)
  end
end
