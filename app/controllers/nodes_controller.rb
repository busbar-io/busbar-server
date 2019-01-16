class NodesController < ApplicationController
  def index
    nodetypes_path = File.join(Rails.root, 'config', 'nodetypes.yml')
    render json: YAML.load_file(nodetypes_path)
  end
end
