require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module PriceComparator
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])

    config.autoload_paths << Rails.root.join('app/services')
    config.autoload_paths << Rails.root.join('app/services/parsers')

    config.time_zone = 'Moscow'
    config.active_record.default_timezone = :local

    config.api_only = false
  end
end