require 'http'

# Returns all configuration belonging to the project
class GetConfigurationDetails
  def initialize(config)
    @config = config
  end

  def call(auth_token:, configuration_id:)
    response = HTTP.auth("Bearer #{auth_token}")
                   .get("#{@config.API_URL}/configurations/#{configuration_id}")
    response.code == 200 ? extract_configuration_details(response.parse) : nil
  end

  private

  def extract_configuration_details(config_data)
    project_data = config_data['relationships']['project']
    project = { 'project' => { 'id' => project_data['id'] }
              .merge(project_data['attributes']) }

    { 'id' => config_data['id'] }
      .merge(config_data['attributes'])
      .merge(project)
  end
end
