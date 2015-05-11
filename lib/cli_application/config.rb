module CliApplication
  class Config
    attr_reader :config

    def initialize(folders)
      @folders = folders
      @filenames = Array.new
      @config_filename = File.join([folders[:class], 'config.yml'])
      load_config(@config_filename)
    end

    def add(filename, type)
      load_config(File.join(@folders[type], filename))
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

      valid?

      ::Time.zone = @config[:cli][:tz]
    end

    def valid?
      raise "ОШИБКА: не найдена секция 'cli'" if @config[:cli].nil?
      raise "ОШИБКА: не найдена секция 'cli.tz'" if @config[:cli][:tz].nil?
      raise "ОШИБКА: не найдена секция 'cli.active_record_tz'" if @config[:cli][:active_record_tz].nil?
    end


  end
end