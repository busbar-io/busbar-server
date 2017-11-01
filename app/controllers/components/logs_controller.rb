class Components::LogsController < ApplicationController
  before_action :load_component

  def show
    @log = ComponentService.retrieve_log(@component, params[:size])

    respond_to do |format|
      format.json { render status: :ok }
    end
  end

  private

  def load_component
    @component = Component.find_by(
      environment_id: environment.id,
      type: params[:component_type]
    )
  end

  def environment
    Environment.find_by(name: params[:environment_name], app_id: params[:app_id])
  end
end
