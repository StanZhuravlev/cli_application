module CliApplication
  class Config < OpenStruct
    attr_reader :config

    def initialize(folders)
      super(nil)
      return if folders.nil?
      @folders = folders
      @filenames = Array.new
      @config_filename = File.join([folders[:class], 'config.yml'])
      load_config(@config_filename)
    end

    def add(filename, type)
      if @folders.keys.include?(type)
        load_config(File.join(@folders[type], filename))
      else
        warn "Предупреждение: попытка загрузить конфиг неизвестного типа (#{type.inspect}). Допустимы #{@folders.keys.inspect}"
      end
    end

    def load_config(filename)
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
    end

    def set_pair(key, value)
      name = new_ostruct_member(key)
      self[name] = value
    end

    def valid?
      raise "ОШИБКА: не найдена секция 'cli'" if self.cli.nil?
      raise "ОШИБКА: не найдена секция 'cli.tz'" if self.cli.timezone.nil?
      raise "ОШИБКА: не найдена секция 'cli.active_record_tz'" if self.cli.ar_timezone.nil?
    end


  end
end