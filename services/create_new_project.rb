# frozen_string_literal: true

require 'http'

# Returns all projects belonging to an account
class CreateNewProject
  def initialize(config)
    @config = config
  end

  def call(auth_token:, new_project:)
    response = HTTP.auth("Bearer #{auth_token}")
                   .post("#{@config.API_URL}/projects",
                         json: new_project)
    new_project = response.parse
    response.code == 201 ? new_project : nil
  end
end
