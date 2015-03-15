require "acapi/config/environment"
# require "acapi/config/options"

module Acapi
  module Config
    extend self


    def load!(path, environment = nil)
      settings = Environment.load_yaml(path, environment)
      if settings.present?
        load_configuration(settings)
      end
      settings
    end

    def load_configuration(settings)
      configuration = settings.with_indifferent_access
      self.options = configuration[:options]
      self.sessions = configuration[:sessions]
    end

    def options=(options)
      if options
        options.each_pair do |option, value|
          Validators::Option.validate(option)
          send("#{option}=", value)
        end
      end
    end

  end
end