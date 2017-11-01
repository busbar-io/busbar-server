class DeploymentsController < ApplicationController
  before_action :load_environment

  def create
    @deployment = DeploymentService.create(@environment, deployment_params, deployment_options)

    respond_to do |format|
      if @deployment.persisted?
        format.json { render status: :created }
      else
        format.json { render status: :unprocessable_entity }
      end
    end
  end

  private

  def deployment_options
    params.permit(:build, :sync).merge(notifiy: true)
  end

  def deployment_params
    params.permit(:branch, :buildpack_id)
  end

  def load_environment
    @environment = Environment.find_by(name: params[:environment_name], app_id: params[:app_id])
  end
end
