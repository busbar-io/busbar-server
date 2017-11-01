settings = { clients: { default: { uri: Configurations.mongoid.uri } } }

Mongoid.load_configuration(settings)

Mongo::Logger.logger.level = ::Logger::INFO unless Rails.env.development?
