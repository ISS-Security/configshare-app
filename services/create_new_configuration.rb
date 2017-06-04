# frozen_string_literal: true

require 'http'

# Create a new configuration file for a project
class CreateNewConfiguration
  def initialize(config)
    @config = config
  end

  def call(auth_token:, project_id:, configuration_data:)
    config_url = "#{@config.API_URL}/projects/#{project_id}/configurations"

    response = HTTP.accept('application/json')
                   .auth("Bearer #{auth_token}")
                   .post(config_url, json: configuration_data)
    new_configuration = response.parse
    response.code == 201 ? new_configuration : nil
  end
end
