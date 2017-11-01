class AppsController < ApplicationController
  before_action :load_app, only: %i(show update destroy)

  def index
    @apps = App.all

    respond_to do |format|
      format.json { render status: :ok }
    end
  end

  def show
    respond_to do |format|
      format.json { render status: :ok }
    end
  end

  def create
    AppProcessing.perform_async(app_params, options_params, environment_params)

    respond_to do |format|
      format.json { head :accepted }
    end
  end

  def update
    respond_to do |format|
      if @app.update_attributes(app_params)
        format.json { render status: :ok }
      else
        format.json { render status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      AppService.destroy(@app)

      format.json { head :no_content }
    end
  end

  private

  def app_params
    params.permit(:id, :buildpack_id, :repository, :public, :default_branch, :default_node_id)
  end

  def options_params
    params.permit(:default_env)
  end

  def environment_params
    params.permit(
      environment: [
        :id,
        :name,
        :buildpack_id,
        :public,
        :default_branch,
        :app_id,
        :default_node_id
      ]).tap do |whitelisted|
        if params[:environment].present?
          whitelisted[:environment][:settings] = params[:environment][:settings]
        end
      end
  end

  def load_app
    @app = App.find(params[:id])
  end
end
