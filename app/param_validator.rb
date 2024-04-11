# frozen_string_literal: true

require 'json_schemer'

class ParamValidatorError < StandardError; end

# Validates params
class ParamValidator
  SCHEMER = JSONSchemer.schema(Pathname.new(File.expand_path('./config/endpoint_schema.json')))

  class << self
    def validate!(params)
      errors = SCHEMER.validate(params).to_a
      raise ParamValidatorError.new, errors.map { |e| e['error'] }.join(', ') if errors.any?
    end
  end
end
