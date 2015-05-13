# Класс обесечивает формирвоание конфигураций баз данных в совместимом с Rails формате

module CliApplication
  class Databases

    # Конструктор, который обеспечивает конфигурацию базового класса ActiveRecords::Base,
    # а именно загружает в класс все конфигурации, с которыми должно работать приложение.
    def initialize(config)
      @config = config.to_h || Hash.new
      ar_configuration
    end

    # Метод возвращает список конфигураций баз данных
    #
    # @return [Array] массив названий конфигураций
    # @example Примеры использования
    #   puts databases.list    #=> [:default, :stat, :work_instance]
    def list
      @config.keys
    end

    # Метод возвращает конфигурацию базы данных
    #
    # @param [Sym] ind идентификатор (наименование) конфигурации базы данных
    # @return [Hash] конфигурация базы данных
    def [](ind)
      @config[ind]
    end

    private

    def ar_configuration # :nodoc:
      list.each do |cfg_name|
        ActiveRecord::Base.configurations[cfg_name] = @config[cfg_name].symbolize_keys
      end
    end

  end
end