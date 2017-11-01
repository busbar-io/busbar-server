require 'yaml'

nodetypes_path = File.join(Rails.root, 'config', 'nodetypes.yml')

Node.collection = YAML.load_file(nodetypes_path)
