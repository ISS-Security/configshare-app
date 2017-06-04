# frozen_string_literal: true

require_relative 'security'
require_relative 'base'

Dir.glob("#{File.dirname(__FILE__)}/**/*.rb").each do |file|
  require file
end
