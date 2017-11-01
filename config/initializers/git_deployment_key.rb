#
# git_deployment_key.rb - Create deployment key file
#

def create_deployment_key_file
  # Creates the id_rsa file
  deployment_key_file = Configurations.git.deployment_key_file
  deployment_key = Configurations.git.deployment_key

  unless File.exist?(deployment_key_file)
    File.open(deployment_key_file, 'w') { |file| file.write(deployment_key) }
  end

  # Fix permissions
  system("chmod 0600 #{deployment_key_file}")
end

create_deployment_key_file
