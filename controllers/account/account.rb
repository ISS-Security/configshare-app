# frozen_string_literal: true

require 'sinatra'

# Account related routes
class ShareConfigurationsApp < Sinatra::Base
  def authenticate_login(auth)
    @current_account = auth['account']
    @auth_token = auth['auth_token']
    current_session = SecureSession.new(session)
    current_session.set(:current_account, @current_account)
    current_session.set(:auth_token, @auth_token)
  end

  def github_sso_url
    gh_url = 'https://github.com/login/oauth/authorize'
    client_id = settings.config.GH_CLIENT_ID
    scope = 'user:email'
    "#{gh_url}?client_id=#{client_id}&scope=#{scope}"
  end

  get '/auth/login/?' do
    @gh_url = github_sso_url
    slim :login
  end

  post '/auth/login/?' do
    credentials = LoginCredentials.call(params)

    if credentials.failure?
      flash[:error] = 'Please enter both username and password'
      redirect '/auth/login'
    end

    auth = FindAuthenticatedAccount.new(settings.config)
                                   .call(credentials)

    if auth
      authenticate_login(auth)
      flash[:notice] = "Welcome back #{@current_account['username']}"
      redirect '/'
    else
      flash[:error] = 'Your username or password did not match our records'
      redirect '/auth/login/'
    end
  end

  get '/auth/logout/?' do
    @current_account = nil
    SecureSession.new(session).delete(:current_account)
    flash[:notice] = 'You have logged out - please login again to use this site'
    redirect '/auth/login'
  end

  get '/github_callback/?' do
    begin
      sso_account = FindAuthenticatedGithubAccount.new(settings.config)
                                                  .call(params['code'])
      authenticate_login(sso_account)
      redirect '/projects'
    rescue => e
      flash[:error] = 'Could not sign in using Github'
      logger.error "FAIL: oauth callback: #{e}"
      redirect '/auth/login'
    end
  end

  get '/account/:username' do
    halt_if_incorrect_user(params)

    slim(:account)
  end
end
