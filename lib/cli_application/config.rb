# Класс обеспечивает чтение различных конфиг-файлов и их объединение в единый интерфейс.
# Например, при задании конфига вида
#
# cli:
#   timezone: 3
#
# к указанным переменным можно получить доступ через вызов puts config.cli.timezone   #=> 3
#

module CliApplication
  class Config < OpenStruct
    attr_reader :config

    # Конструктор. Вызывается при создании класса приложения. Данный класс доступен
    # в главной функции приложения (main) через переменную config
    #
    # @param [Array] folders директории, в которых расположены базовый класс проекта и класс приложения
    def initialize(folders)
      super(nil)
      return if folders.nil?
      @folders = folders
      @filenames = Array.new
      @config_filename = File.join([folders[:class], 'config.yml'])
      load_config(@config_filename)
    end

    # Метод загружает конфиг и делает его доступным через единый интерфейс настроек конфигурации приложения (CliApplication::Config)
    # При каждом вызове данного метода все конфиги перечитываются заново.
    #
    # @param [Sym] type параметр используется для указания местоположения конфига. Если указано :app или :class,
    #   то имя файла с конфигом будет дополнено папкой класса или приложения
    # @option type [Sym] :app папка, из которой запущено приложение
    # @option type [Sym] :class папка, в которой хранится базовый класс
    # @option type [Sym] :absolute указывает на необходимость брать имя файла как задано разработчиком
    # @return [Nil] нет
    def add(filename, type)
      if @folders.keys.include?(type)
        load_config(File.join(@folders[type], filename))
      elsif type == :absolute
        load_config(filename)
      else
        warn "Предупреждение: попытка загрузить конфиг неизвестного типа (#{type.inspect}). Допустимы #{@folders.keys.inspect}"
      end
    end


    private


    def load_config(filename) # :nodoc:
      raise "Внимание!!! Не найден файл конфигурации '#{filename}'" unless File.exist?(filename)
      @filenames << filename
      @filenames.uniq!
      @config = Hash.new

      @filenames.each do |one|
        tmp = YAML.load_file(one).deep_symbolize_keys rescue Hash.new
        @config.merge!(tmp)
      end

      tmp = JsonStruct.new(@config)
      tmp.each_pair { |key, value| set_pair(key, value)  }
      valid?

      ::Time.zone = self.cli.timezone
      ::ActiveRecord::Base.default_timezone = self.cli.ar_timezone
    end

    def set_pair(key, value)  # :nodoc:
      name = new_ostruct_member(key)
      self[name] = value
    end

    def valid? # :nodoc:
      raise "ОШИБКА: не найдена секция 'cli'" if self.cli.nil?
      raise "ОШИБКА: не найдена секция 'cli.tz'" if self.cli.timezone.nil?
      raise "ОШИБКА: не найдена секция 'cli.active_record_tz'" if self.cli.ar_timezone.nil?
    end


  end
end