class Components::ResizeController < ApplicationController
  before_action :load_component

  def update
    if Configurations.service.provider == 'minikube'
      puts 'Resize not allowed when using minikube provider'
      render json: "Resize not allowed when using minikube provider", status: :bad_request

    else
      if Node.find(params[:node_id])
        Components::ResizeProcessing.perform_async(@component.id.to_s, params[:node_id])
        respond_to do |format|
          format.json { head :accepted }
        end
      else
        respond_to do |format|
          format.json { head :unprocessable_entity }
        end
      end
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
