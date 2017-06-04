# frozen_string_literal: true

require 'http'

# Returns all projects belonging to an account
class AddCollaboratorToProject
  def initialize(config)
    @config = config
  end

  def call(auth_token:, collaborator_email:, project_id:)
    config_url = "#{@config.API_URL}/projects/#{project_id}/collaborators"

    response = HTTP.accept('application/json')
                   .auth("Bearer #{auth_token}")
                   .post(config_url,
                         json: { email: collaborator_email })

    response.code == 201 ? response.parse : nil
  end
end
