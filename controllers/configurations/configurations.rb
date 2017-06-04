# frozen_string_literal: true

require 'sinatra'

# Base class for ConfigShare Web Application
class ShareConfigurationsApp < Sinatra::Base
  get '/configurations/:config_id' do
    begin
      @config_file = GetConfigurationDetails.new(settings.config).call(
        auth_token: @auth_token,
        configuration_id: params[:config_id]
      )

      slim :configuration
    rescue => e
      logger.error "GET CONFIG FAILED: #{e}"
      flash[:error] = 'Could not get that configuration file'
      redirect '/projects'
    end
  end

  get '/configurations/:config_id/document' do
    begin
      @config_file = GetConfigurationDetails.new(settings.config).call(
        auth_token: @auth_token,
        configuration_id: params[:config_id]
      )

      content_type 'application/octet-stream'
      headers['Content-Disposition'] =
        "attachment;filename=#{@config_file['filename']}"
      Base64.strict_decode64 @config_file['document']
    rescue => e
      logger.error "GET CONFIG FAILED: #{e}"
      flash[:error] = 'Could not get that configuration file'
      redirect "/configurations/#{params[:config_id]}"
    end
  end
end
