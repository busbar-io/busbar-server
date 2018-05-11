#
# service_provider.rb - Load Service Provider related settings
#

# Service provider selection
if Configurations.service.provider == 'minikube'
  puts 'minikube! \o/'

elsif Configurations.service.provider == 'aws'
  # Requires
  require 'ec2_metadata'

  # Configure Region
  aws_region = if Rails.env.test?
                 'us-east-1'
               elsif !Configurations.aws.region.nil?
                 Configurations.aws.region
               else
                 Ec2Metadata['meta-data']['placement']['availability-zone'].chop
               end

  Aws.config.update(region: aws_region)

  # Configure Credentials
  if Rails.env == 'test'
    Aws.config.update(stub_responses: true)
    credentials = Aws::Credentials.new('fake', 'fake')
  elsif !Configurations.aws.access_key_id.nil?
    credentials = Aws::Credentials.new(Configurations.aws.access_key_id,
                                       Configurations.aws.secret_access_key)
  else
    credentials = Aws::InstanceProfileCredentials.new
  end

  Aws.config.update(credentials: credentials)

  # Initialize Objects
  Route53 = Aws::Route53::Client.new
  ElasticLoadBalancer = Aws::ElasticLoadBalancing::Client.new
  Ec2Client = Aws::EC2::Client.new
end
