require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module SignalCI
  class Application < Rails::Application
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.action_controller.page_cache_directory = Rails.root.join("public/cache")
    if Rails.root.join("config/mailer.yml").file?
      MAILER = YAML.load_file(Rails.root.join("config/mailer.yml"))
      config.action_mailer.smtp_settings = {
        :address          => MAILER['address'],
        :port             => MAILER['port'],
        :domain           => MAILER['domain'],
        :user_name        => MAILER['user_name'],
        :password         => MAILER['password'],
        :authentication   => MAILER['authentication'],
        :enable_starttls_auto => MAILER['enable_starttls_auto']
      }
    end
  end
end
