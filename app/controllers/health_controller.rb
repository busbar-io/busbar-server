class HealthController < ApplicationController
  def check
    render text: 'ok', status: :ok
  end
end
