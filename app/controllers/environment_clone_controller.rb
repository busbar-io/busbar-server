class EnvironmentCloneController < ApplicationController
  before_action :load_environment, only: %i(create)

  def create
    EnvironmentCloneProcessing.perform_async(@environment.id, params[:clone_name])

    respond_to do |format|
      format.json { head :accepted }
    end
  end

  private

  def load_environment
    @environment = Environment.find_by(name: params[:environment_name], app_id: params[:app_id])
  end
end
