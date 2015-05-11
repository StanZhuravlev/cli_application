module CliApplication
  class App
    attr_reader :argv, :exitcode, :folders, :config
    attr_reader :version, :description, :shortdescription, :releasedate
    attr_reader :databases

    def initialize(argv, appfolder, classfolder, lang = :ru)
      ::StTools::Setup.setup(lang)

      @folders = Hash.new
      @folders[:app] = appfolder
      @folders[:class] = classfolder

      @argv = ::CliApplication::Argv.new(argv)
      @stat = ::CliApplication::Stat.new(@folders)
      @config = ::CliApplication::Config.new(@folders)

      @mysql = ::CliApplication::Databases.new(@config.config[:cli][:databases])

      init_app
    end

    #-------------------------------------------------------------
    #
    # Функции для использования внутри функции main
    #
    #-------------------------------------------------------------

    # Метод возвращает папку из которой запущено приложение или расположен базовый класс.
    # Базовый класс обычно располагается в фиксированном месте, например, в папке cli корня проекта. Соответственно,
    # если вызвать File.dirname(app.folder(:class)), то можно будет узнать корневую папку проекта
    #
    # @param [Sym] type тип возвращаемой папки
    # @option type [Sym] :app папка, из которой запущено приложение (по умолчанию)
    # @option type [Sym] :class папка, в которой хранится базовый класс
    # @option type [Sym] :stat папка, в которой хранится статистика по приложению
    # @return [String] папка, из которой запущено приложение или расположен базовый класс
    def folder(type = :app)
      warn "Предупреждение: тип папки '#{type.inspect}' неизвестен (допустимо #{@folders.keys.inspect})" unless @folders.keys.include?(type)
      @folders[type]
    end

    # Метод загружает конфиг и делает его доступным через единый интфрейс настроек конфигурации приложения
    #
    # @param [Sym] type тип конфига
    # @option type [Sym] :app папка, из которой запущено приложение
    # @option type [Sym] :class папка, в которой хранится базовый класс
    # @return [Nil] нет
    def add_config(filename, type)
      @config.add(filename, type)
    end

    # Метод возвращает имя приложения
    #
    # @return [String] имя приложения без параметров командной строки и пути
    def exename
      ::StTools::System.exename
    end


    #-------------------------------------------------------------
    #
    # Функции настройки приложения
    #
    #-------------------------------------------------------------
    def executed_at=(at)
      @executed_at = at
      @stat.executed_at = at
    end

    def executed_at
      @executed_at = (::Time.now - @started_at).to_f
    end

    def exitcode=(code)
      @exitcode = code
      @stat.exitcode = code
    end

    def version=(val)
      @version = val
      @stat.version = val
    end

    def description=(val)
      @description = val
      @stat.description = val
    end

    def shortdescription=(val)
      @shortdescription = val
      @stat.shortdescription = val
    end

    def releasedate=(val)
      @releasedate = val
      @stat.releasedate = val
    end

    def init_active_records

    end

    def init_app
      @stat.last_started_at = ::Time.zone.now
      @started_at = ::Time.now
      @exitcode = 0

      init_active_records
    end

    def set_appconfig(name)
      @config.load_config(@folders[:class] + '/' + name)
      @stat.timezone = @config.config[:cli][:tz]
    end


    def set_argv(action, key, default, description)
      @argv.set_argv(action, key, default, description)
    end

    def main
      warn "ПРЕДУПРЕЖДЕНИЕ: необходимо переопределить функцию 'main' в вашем коде"
      255
    end

    def run
      self.exitcode = main || 255
      self.executed_at = (::Time.now - @started_at).to_f
      @stat.save
    end

    def help(type = :full)
      last_started_at_human = @stat.last_started_at_human

      puts ::StTools::System.exename + ' - ' + @shortdescription
      puts "Версия #{@version} (#{@releasedate})"
      puts last_started_at_human
      puts @stat.startes_human
      puts
      puts @description

      if type == :full
        @argv.help
        puts
      end
    end

  end
end