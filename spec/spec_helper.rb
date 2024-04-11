# frozen_string_literal: true

require 'rack/test'
require 'rspec'
require_relative '../app/server'

set :environment, :test

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

def app
  Sinatra::Application
end

def json_body
  JSON.parse(last_response.body)
end
