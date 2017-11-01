class ScaleController < ApplicationController
  before_action :load_environment
  before_action :load_component

  def show
    respond_to do |format|
      format.json { render status: :ok, json: { scale: @component.scale } }
    end
  end

  def update
    ScaleProcessing.perform_async(@component.id.to_s, params[:scale])

    respond_to do |format|
      format.json { head :accepted }
    end
  end

  private

  def load_environment
    @environment = Environment.find_by(name: params[:environment_name], app_id: params[:app_id])
  end

  def load_component
    @component = Component.find_by(
      environment_id: @environment.id,
      type: params[:component_type]
    )
  end
end
