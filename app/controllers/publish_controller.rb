class PublishController < ApplicationController
  before_action :load_environment

  def update
    PublishProcessing.perform_async(@environment.id)
    respond_to do |format|
      format.json { head :accepted }
    end
  end

  private

  def load_environment
    @environment = Environment.find_by(name: params[:environment_name], app_id: params[:app_id])
  end
end
