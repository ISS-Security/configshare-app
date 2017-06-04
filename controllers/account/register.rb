# frozen_string_literal: true

require 'sinatra'

# Account related routes
class ShareConfigurationsApp < Sinatra::Base
  get '/account/register/?' do
    slim :register
  end

  post '/account/register/?' do
    registration = Registration.call(params)
    if registration.failure?
      flash[:error] = 'Please enter a valid username and email'
      redirect 'account/register'
      halt
    end

    begin
      EmailRegistrationVerification.new(settings.config).call(
        username: params[:username],
        email: params[:email]
      )
      flash[:notice] = 'A verification email has been sent to you. '\
                       'Please check your email.'
      redirect '/'
    rescue => e
      logger.error "FAIL EMAIL: #{e}"
      flash[:error] = 'Unable to send email verification -- please '\
                      'check you have entered the right email address'
      redirect '/account/register'
    end
  end

  get '/account/register/:token_secure/verify' do
    @token_secure = params[:token_secure]
    @new_account = SecureMessage.decrypt(@token_secure)

    slim :register_confirm
  end

  post '/account/register/:token_secure/verify' do
    passwords = Passwords.call(params)
    if passwords.failure?
      flash[:error] = passwords.messages.values.join('; ')
      redirect "/account/register/#{params[:token_secure]}/verify"
      halt
    end

    new_account = SecureMessage.decrypt(params[:token_secure])
    result = CreateVerifiedAccount.new(settings.config).call(
      username: new_account['username'],
      email: new_account['email'],
      password: passwords[:password]
    )

    if result
      flash[:notice] = 'Please login with your new username and password'
      redirect '/auth/login'
    else
      flash[:error] = 'Your account could not be created. Please try again'
      redirect '/account/register'
    end
  end
end
