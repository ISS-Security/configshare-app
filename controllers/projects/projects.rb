require 'sinatra'

# Base class for ConfigShare Web Application
class ShareConfigurationsApp < Sinatra::Base
  get '/projects/?' do
    begin
      @projects = GetAllProjects.new(settings.config)
                                .call(current_account: @current_account,
                                      auth_token: @auth_token)
      slim(:projects_all)
    rescue
      status 501
      redirect('/auth/login')
    end
  end

  get '/projects/:project_id/?' do
    begin
      raise unless @current_account
      @project = GetProjectDetails.new(settings.config)
                                  .call(project_id: params[:project_id],
                                        auth_token: @auth_token)
      raise unless @project
      slim(:project)
    rescue
      flash[:error] = 'Could not retrieve this project'
      redirect '/auth/login'
    end
  end

  post '/projects/:project_id/collaborators/?' do
    collaborator = AddCollaboratorToProject.new(settings.config).call(
      auth_token: @auth_token,
      collaborator_email: params[:email],
      project_id: params[:project_id]
    )

    if collaborator
      collab_info = "#{collaborator['username']} (#{collaborator['email']})"
      flash[:notice] = "Added #{collab_info} to the project"
    else
      flash[:error] = "Could not add #{params['email']} to the project"
    end

    redirect back
  end

  post '/projects/?' do
    begin
      new_project_data = NewProject.call(params)
      if new_project_data.failure?
        flash[:error] = new_project_data.messages.values.join('; ')
        raise
      end

      new_project = CreateNewProject.new(settings.config).call(
        auth_token: @auth_token,
        new_project: new_project_data.to_h
      )
      flash[:notice] = 'Your new project has been created! '\
                       ' Now add configurations and invite collaborators.'
      redirect "/projects/#{new_project['id']}"

    rescue => e
      flash[:error] ||= 'Something went wrong -- we will look into it!'
      logger.error "NEW_PROJECT FAIL: #{e}"
      redirect '/projects'
    end
  end

  post '/projects/:project_id/configurations' do
    project_url = "/projects/#{params[:project_id]}"
    begin
      new_config_data = NewConfiguration.call(params)

      if new_config_data.failure?
        flash[:error] = 'Configuration details invalid: ' +
                        new_config_data.messages.values.join('; ')
        raise
      end

      new_config = CreateNewConfiguration.new(settings.config).call(
        auth_token: @auth_token,
        project_id: params[:project_id],
        configuration_data: new_config_data.to_h
      )
      flash[:notice] = 'Here is your new configuration file!'
      redirect "/configurations/#{new_config['id']}"
    rescue => e
      flash[:error] = 'Something went wrong -- we will look into it!'
      logger.error "NEW CONFIGURATION FAIL: #{e}"
      redirect project_url
    end
  end
end
