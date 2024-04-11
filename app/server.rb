# frozen_string_literal: true

require 'sinatra'
require 'json'
require_relative 'param_validator'
require_relative 'storage'

before do
  content_type 'application/vnd.api+json'
  @params = Sinatra::IndifferentHash.new
end

# Chose an in-memory storage to reduce the overhead of testing this locally.
# Any persistent storage method could've been implemented, ie: PostgreSQL, DynamoDB, etc.
ephemeral = MemoryStorage.new

get '/endpoints' do
  [200, { data: ephemeral.storage }.to_json]
end

post '/endpoints' do
  @params.merge!(JSON.parse(request.body.read))
  ParamValidator.validate!(@params)
  [201, location_header(@params[:data][:attributes][:path]), ephemeral.create(@params).to_json]
rescue ParamValidatorError, JSON::ParserError => e
  invalid_params(e)
end

patch '/endpoints/:id' do
  pass if request.body.read == ''
  request.body.rewind
  @params.merge!(JSON.parse(request.body.read))
  ParamValidator.validate!(@params)
  response = ephemeral.update(params[:id], @params)
  return response.to_json if response

  not_found
rescue ParamValidatorError, JSON::ParserError => e
  invalid_params(e)
end

delete '/endpoints/:id' do
  ephemeral.delete(params[:id]) ? 204 : not_found
end

def handle_all_methods(path, &block)
  %w[get post put delete patch options].each do |method|
    send(method, path, &block)
  end
end

handle_all_methods '*' do
  response = ephemeral.find_endpoint(request.request_method, request.path_info)
  response.empty? ? not_found : response
end

not_found do
  status 404
  {
    errors: [
      {
        code: 'not_found',
        detail: "Requested endpoint `#{request.request_method}` `#{request.path_info}` does not exist"
      }
    ]
  }.to_json
end

def invalid_params(e)
  status 400
  {
    errors: [
      {
        code: 'invalid_payload',
        detail: e
      }
    ]
  }.to_json
end

def location_header(endpoint)
  server_host = request.env['HTTP_HOST'] || request.host
  server_port = request.env['SERVER_PORT'] || request.port

  location = "#{request.scheme}://#{server_host}:#{server_port}#{endpoint}"
  { 'Location' => location }
end
