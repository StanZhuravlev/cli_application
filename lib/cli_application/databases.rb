module CliApplication
  class Databases

    def initialize(config)
      @config = config || Hash.new
      ar_configuration
    end

    def list
      @config.keys
    end

    def [](ind)
      @config[ind]
    end

    def ar_configuration
      list.each do |cfg_name|
        ActiveRecord::Base.configurations[cfg_name] = @config[cfg_name].symbolize_keys
      end
    end

  end
end