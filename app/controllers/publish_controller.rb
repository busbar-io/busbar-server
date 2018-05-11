class PublishController < ApplicationController
  before_action :load_environment

  def update
    if Configurations.service.provider == 'minikube'
      puts 'Publish not allowed when using minikube provider'
      render json: 'Publish not allowed when using minikube provider', status: :bad_request
    else
      PublishProcessing.perform_async(@environment.id)
      respond_to do |format|
        format.json { head :accepted }
      end
    end
  end

  private

  def load_environment
    @environment = Environment.find_by(name: params[:environment_name], app_id: params[:app_id])
  end
end
