# frozen_string_literal: true

# Storage
class MemoryStorage
  attr_accessor :storage

  def initialize
    @storage = []
  end

  def find_endpoint(method, endpoint)
    response = []
    @storage.each do |item|
      next unless item[:attributes][:verb] == method && item[:attributes][:path] == endpoint

      response = [
        item[:attributes][:response][:code],
        item[:attributes][:response][:headers],
        item[:attributes][:response][:body].delete_prefix('"').delete_suffix('"')
      ]
    end
    response
  end

  def create(endpoint)
    # TO DO: implement duplicated ID check.
    endpoint[:data][:id] = rand(1..10_000)
    @storage << endpoint[:data]
    endpoint
  end

  def update(id, endpoint)
    @storage.each do |item|
      next unless item[:id] == id.to_i

      @storage.delete(item)
      endpoint[:data][:id] = id.to_i
      @storage << endpoint[:data]
      return endpoint
    end
    false
  end

  def delete(id)
    @storage.each do |item|
      next unless item['id'] == id.to_i

      @storage.delete(item)
      return true
    end
    false
  end
end
