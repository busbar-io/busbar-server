class EnvironmentsController < ApplicationController
  before_action :load_environment, only: %i(show update destroy)
  before_action :load_app, only: %i(index create)

  def index
    @environments = @app.environments

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
    @environment = EnvironmentService.create(@app, environment_create_params)

    respond_to do |format|
      if @environment.persisted?
        format.json { render status: :created }
      else
        format.json { render status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @environment.update_attributes(environment_update_params)
        format.json { render status: :ok }
      else
        format.json { render status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      EnvironmentService.destroy(@environment)

      format.json { head :no_content }
    end
  end

  private

  def environment_create_params
    params.permit(:id, :name, :buildpack_id, :public,
                  :default_branch, :app_id, :type,
                  :default_node_id, settings: setting_params)
  end

  def setting_params
    (params[:settings] || {}).keys
  end

  def environment_update_params
    params.permit(:id, :name, :buildpack_id, :default_branch)
  end

  def load_environment
    @environment = Environment.find_by(name: params[:name], app_id: params[:app_id])
  end

  def load_app
    @app = App.find(params[:app_id])
  end
end
