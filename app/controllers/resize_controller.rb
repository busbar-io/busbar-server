class ResizeController < ApplicationController
  before_action :load_environment

  def update
    if Node.find(params[:node_id])
      ResizeProcessing.perform_async(@environment.id, params[:node_id])
      respond_to do |format|
        format.json { head :accepted }
      end
    else
      respond_to do |format|
        format.json { head :unprocessable_entity }
      end
    end
  end

  private

  def load_environment
    @environment = Environment.find_by(name: params[:environment_name], app_id: params[:app_id])
  end
end
