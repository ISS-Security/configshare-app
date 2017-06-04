# frozen_string_literal: true

require 'sinatra'
require 'slim/include'

# Base class for ConfigShare Web Application
class ShareConfigurationsApp < Sinatra::Base
  enable :logging
  set :views, File.expand_path('../../views', __FILE__)
  set :public_dir, File.expand_path('../../public', __FILE__)

  def current_account?(params)
    @current_account && @current_account['username'] == params[:username]
  end

  def halt_if_incorrect_user(params)
    return true if current_account?(params)
    flash[:error] = 'You used the wrong account for this request'
    redirect '/auth/login'
    halt
  end

  before do
    @current_account = SecureSession.new(session).get(:current_account)
    @auth_token = SecureSession.new(session).get(:auth_token)
  end

  get '/' do
    slim :home
  end
end
