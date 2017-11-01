class BuildsController < ApplicationController
  before_action :load_environment

  def latest
    @build = @environment.latest_build

    respond_to do |format|
      format.json { render status: :ok }
    end
  end

  private

  def load_environment
    @environment = Environment.find_by(name: params[:environment_name], app_id: params[:app_id])
  end
end
