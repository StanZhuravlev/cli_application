# CliApplication::App - основной класс - каркас CLI-приложений. Класс обеспечивает контроль
# аргументов командной строки, управление конфигами и подключениями к базе данных.

module CliApplication
  class App
    # Ссылка на класс, который содержит аргменты командной строки или значения по умолчанию
    attr_reader :argv
    # Код завершения приложения. Может быть использован в Bash-скриптах
    attr_reader :exitcode
    # Ссылка на массив, содержащий список директорий в которых исполняется приложение.
    # Основные: folders[:app] - папка из которой запущено приложение, folders[:class] - папка,
    # в которой хранится базовый класс проекта.
    attr_reader :folders
    # Ссылка на класс конфигурации приложения
    attr_reader :config
    # Строка - версия приложения
    attr_reader :version
    # Строка - описание приложения
    attr_reader :description
    # Строка - краткое описание (назначение) приложения
    attr_reader :shortdescription
    # Строка - дата релиза ПО
    attr_reader :releasedate
    # Структура, содержащая конфигурации баз данных
    attr_reader :databases
    # Строка-шаблон, вывод которой происходит после завершения работы приложения
    attr_accessor :footer

    # Конструктор экземпляра приложения
    #
    # @param [Array] argv аргументы командной строки
    # @param [String] appfolder директория, из которой запущено приложение
    # @param [String] classfolder директория, в которой расположен базовый класс проекта
    # @param [Sym] lang язык работы приложения (реализовано не полностью)
    def initialize(argv, appfolder, classfolder, lang = :ru)
      ::StTools::Setup.setup(lang)

      @folders = Hash.new
      @folders[:app] = appfolder
      @folders[:class] = classfolder

      @argv = ::CliApplication::Argv.new(argv)
      @stat = ::CliApplication::Stat.new(@folders)
      @config = ::CliApplication::Config.new(@folders)

      @databases = ::CliApplication::Databases.new(config.cli.databases)

      @footer = nil

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

    # Метод загружает конфиг и делает его доступным через единый интерфейс настроек конфигурации приложения (CliApplication::Config)
    # При каждом вызове данного метода все конфиги перечитываются заново.
    #
    # @param [Sym] type параметр используется для указания местоположения конфига. Если указано :app или :class,
    #   то имя файла с конфигом будет дополнено папкой класса или приложения
    # @option type [Sym] :app папка, из которой запущено приложение
    # @option type [Sym] :class папка, в которой хранится базовый класс
    # @option type [Sym] :absolute указывает на необходимость брать имя файла как задано разработчиком
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

    # Метод возвращает число секунд в формате Float с момента запуска приложения. В основном используется для показа
    # времени выполнения приложения, но может быть вызван в любой момент из любого места приложения.
    #
    # @return [Float] число секунд с момента запуска приложения
    # @example Примеры использования
    #   puts "С момента запуска прошло #{executed_at} сек."     #=> "С момента запуска прошло 23.456435 сек."
    def executed_at
      @executed_at = (::Time.now - @started_at).to_f
    end

    # Метод устанавливает код, с которым будет завершена работа приложения.
    #
    # @param [Integer] code код завершения приложения, который будет передан в операционную систему (bash)
    def exitcode=(code)
      @exitcode = code
      @stat.exitcode = code
    end

    # Метод устанавливает текущую версию приложения, которая потом отобразится в файле статистики
    #
    # @param [Integer] val строка с версией приложения
    # @example Примеры использования
    #   app = CliApplication.new(ARGV, __dir__)
    #   app.version = '2.1'
    def version=(val)
      @version = val
      @stat.version = val
    end

    # Метод устанавливает описание приложения, которое будет выведено при старте скрипта. Данный метод используется
    # для формирования подсказок пользователю.
    #
    # @param [String] val строка с описанием приложения
    # @example Примеры использования
    #   app = CliApplication.new(ARGV, __dir__)
    #   app.description = 'Данное приложение обеспечивает.... (c) .... и т.д.'
    def description=(val)
      @description = val
      @stat.description = val
    end

    # Метод устанавливает краткое описание приложения, которое будет выведено при старте скрипта, а также
    # отображено в файле статистики.
    #
    # @param [String] val строка с кратким описанием приложения
    # @example Примеры использования
    #   app = CliApplication.new(ARGV, __dir__)
    #   app.shortdescription = 'Утилита форматирования диска'
    def shortdescription=(val)
      @shortdescription = val
      @stat.shortdescription = val
    end

    # Метод устанавливает дату последнего изменения (выпуска) приложения. Используется в справочных целях
    #
    # @param [String] val строка датой релиза (выпуска) приложения
    # @example Примеры использования
    #   app = CliApplication.new(ARGV, __dir__)
    #   app.releasedate = '2015-05-11'
    def releasedate=(val)
      @releasedate = val
      @stat.releasedate = val
    end

    # Метод предназначен для подключения файлов-моделей ActiveRecords. Архитектура CLI-приложения, учитывающая
    # совместимость с Rails-проектами, требует загрузки моделей после чтения файлов конфигурации и, соответственно,
    # иницииации класса приложения. Поэтому объявить require файлов моделей в начале файла не получится, будут
    # выводится ошибки инициализации базы данных.
    #
    # @example Примеры использования
    #   def init_active_records
    #     require 'offers.rb'
    #     require 'params.rb'
    #     require 'categories.rb'
    #   end
    def init_active_records

    end

    # Метод инициализации приложения. Может быть переписан с обязательным вызовом функции super
    #
    # @example Примеры использования
    #   def init_app
    #     super
    #
    #     # Код своего приложения
    #   end
    def init_app
      @stat.last_started_at = ::Time.zone.now
      @started_at = ::Time.now
      @exitcode = 0

      init_active_records
    end

    # Метод добавления аргумента командной строки. Вызывается при инициализации приложения, служит для определения списка
    # аргументов командной строки, формирвоания подсказок и установки значения по умолчанию. В классе принят не традиционный
    # для Linux формат командной строки. Пример вызова: add_city.rb user_id=123 name=Максим city='Верхние Луки'.
    #
    # Параметры, добавленные данным методом доступны через переменную argv (см. примеры)
    #
    # @param [Sym] action параметр определяет действие, которое надо произвести над параметром командной строки.
    # @param [String] key название ключа, напрмиер 'user_id', 'name', 'city'.
    # @param [Object] default значение по умочланию, "подставляемое" при отсутствии заданного пользователем параметра
    # @param [String] description описание параметра (подсказка)
    #
    # @example Примеры использования
    #   app = CliApplication.new(ARGV, __dir__)
    #   app.set_argv(:integer, 'user_id', 0, 'Идентификатор пользователя')
    #   app.set_argv(:string, 'name', 'Без имени', 'Имя пользователя')
    #   app.set_argv(:caps, 'city', 'москВА', 'Город проживания пользователя')
    #
    #   def main
    #     puts argv.user_id      #=> 0
    #     puts argv.name         #=> 'Без имени'
    #     puts argv.city         #=> 'Москва'
    #   end
    def set_argv(action, key, default, description)
      @argv.set_argv(action, key, default, description)
    end

    # Основной метод, в котором должен быть размещен код приложения
    # @return [Integer] метод должен возвращать код, который будет транслирован в параметр exitcode
    def main
      warn "ПРЕДУПРЕЖДЕНИЕ: необходимо переопределить функцию 'main' в вашем коде"
      255
    end

    # При вызове данного метода начнется выполнение кода приложения (будет осуществен вызов функции main)
    def run
      self.exitcode = main || 255
      self.executed_at = (::Time.now - @started_at).to_f
      puts_footer
      @stat.save
    end

    # Метод отображает на экране информацию о приложении (версия, дата последнего запуска, дата релиза, и пр.)
    # @param [Syn] type при указании :full выводится полное описание, при других значениях не выводится
    #   подсказка по аргументам командной строки
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


    private


    def puts_footer
      return if @footer.nil?
      line = footer.gsub('{executed_at}', executed_at.to_s)
      line.gsub!('{memory}', StTools::Human.memory)
      line.gsub!('{exitcode}', @exitcode.to_s)
      line.gsub!('{status}', (@exitcode == 0 ? 'SUCCESS' : 'FAIL'))
      puts line
    end

    def executed_at=(at)
      @executed_at = at
      @stat.executed_at = at
    end

  end
end