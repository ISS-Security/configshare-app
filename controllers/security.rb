# frozen_string_literal: true

require 'econfig'
require 'rack-flash'
require 'rack/session/redis'
require 'rack/ssl-enforcer'
require 'secure_headers'

# Security settings for ConfigShare
class ShareConfigurationsApp < Sinatra::Base
  extend Econfig::Shortcut

  ONE_MONTH = 2_592_000 # ~ one month in seconds

  configure :production do
    use Rack::SslEnforcer
  end

  configure do
    Econfig.env = settings.environment.to_s
    Econfig.root = File.expand_path('..', settings.root)

    SecureMessage.setup(settings.config)
    SecureSession.setup(settings.config)
  end

  # configure :development, :test do
  #   use Rack::Session::Pool, expire_after: ONE_MONTH
  # end

  # configure :production do
    use Rack::Session::Redis, expire_after: ONE_MONTH, redis_server: settings.config.REDIS_URL
  # end

  use Rack::Flash

  ## Uncomment to drop the login session in case of any violation
  # use Rack::Protection, reaction: :drop_session
  use SecureHeaders::Middleware

  SecureHeaders::Configuration.default do |config|
    config.cookies = {
      secure: true,
      httponly: true,
      samesite: {
        strict: true
      }
    }

    config.x_frame_options = 'DENY'
    config.x_content_type_options = 'nosniff'
    config.x_xss_protection = '1'
    config.x_permitted_cross_domain_policies = 'none'
    config.referrer_policy = 'origin-when-cross-origin'

    config.csp = {
      report_only: false,
      preserve_schemes: true,
      default_src: %w('self'),
      child_src: %w('self'),
      connect_src: %w(wws:),
      img_src: %w('self'),
      font_src: %w('self' https://maxcdn.bootstrapcdn.com),
      script_src: %w('self' https://code.jquery.com https://maxcdn.bootstrapcdn.com),
      style_src: %w('self' 'unsafe-inline' https://maxcdn.bootstrapcdn.com https://cdnjs.cloudflare.com),
      form_action: %w('self'),
      frame_ancestors: %w('none'),
      plugin_types: %w('none'),
      block_all_mixed_content: true,
      upgrade_insecure_requests: true,
      report_uri: %w(/security/report_csp_violation)
    }
  end

  post '/security/report_csp_violation' do
    logger.info("CSP VIOLATION: #{request.body.read}")
  end
end
