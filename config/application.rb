require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv::Railtie.load

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.i18n.available_locales = [:en, :ru, :uk]
    config.i18n.default_locale = :ru
    config.i18n.locale = :ru

    config.action_cable.mount_path = '/websocket'
    config.action_cable.allowed_request_origins = ['https://' + ENV['VIRTUAL_HOST'], 'http://railstest']

    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.perform_caching = false
    config.action_mailer.default_url_options = { host: 'https://' + ENV['VIRTUAL_HOST'] }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:         ENV['SMTP_ADDRESS'],
      port:            ENV['SMTP_PORT'],
      domain:          ENV['SMTP_DOMAIN'],
      user_name:       ENV['SMTP_USERNAME'],
      password:        ENV['SMTP_PASSWORD'], 
      authentication: 'login',
      tls:             true,
      enable_starttls_auto: true,
    }
    config.action_mailer.default_options = {from: 'no-reply@' + ENV['VIRTUAL_HOST']}
    config.action_mailer.deliver_later_queue_name = 'mailers'

    config.active_job.queue_adapter = :sidekiq
    config.active_storage.queues.analysis = :default
    config.active_storage.queues.purge = :default

    config.active_storage.queues.analysis = :default
    
    config.session_store :cookie_store, key: '_rails_app_session'

    cache_servers = ENV.fetch("REDIS_URL", "redis://localhost:6379/1")
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :redis_cache_store, { url: cache_servers,
 
      connect_timeout:    30,  # Defaults to 20 seconds
      read_timeout:       0.2, # Defaults to 1 second
      write_timeout:      0.2, # Defaults to 1 second
      reconnect_attempts: 1,   # Defaults to 0
 
      error_handler: -> (method:, returning:, exception:) {
        # Report errors to Sentry as warnings
        Raven.capture_exception exception, level: 'warning',
         tags: { method: method, returning: returning }
      }
    }

    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc
    config.beginning_of_week = :monday

    Rails.application.config.hosts << ENV['VIRTUAL_HOST']

    config.active_record.database_selector = { delay: 30.seconds }
    config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
    config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
