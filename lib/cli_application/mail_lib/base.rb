# CliApplication::MailLib::Base - базовый класс валидации конфига почты

module CliApplication
  module MailLib
    class Base # :nodoc:
      attr_reader :delivery_method
      attr_reader :config_fail_message

      def initialize(config, folders) # :nodoc:
        @config = config
        @folders = folders
      end

      # Метод возвращает true, если подсистема отсылки почтовых сообщений настроена корректна
      # и готова к рассылке сообщений
      #
      # @return [Boolean] true - если подсистема почта настроена корректно
      def valid?
        @is_valid
      end

      # Метод является заглушкой функции, которая должна быть переписана в дочерних классах
      # ::Log, ::Error, ::Smpt, ::Sendmail
      #
      # @param [String] электронная почта лица, которому отправляется сообщение, или массив адресов
      # @param [String] name имя клиента, которому отправляется сообщение
      # @param [String] title заголовок письма
      # @param [String] body текст письма
      # @return [Boolean] true, если письмо отправлено
      def simple_send(to, name, title, body)
        warn "Необходимо переопределить функцию отправки электронной почты (simple_send)"
        warn "Обратитесь к разработчику данного скрипта"
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Log
      #
      # @return [String] пустая строка
      def log_filename
        ''
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Smtp
      #
      # @return [String] пустая строка
      def address
        ''
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Smtp
      #
      # @return [String] пустая строка
      def domain
        ''
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Smtp
      #
      # @return [String] пустая строка
      def port
        ''
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Smtp
      #
      # @return [String] пустая строка
      def user_name
        ''
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Smtp
      #
      # @return [Boolean] необходимость использовать SSL/TLS
      def tls?
        false
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Smtp
      #
      # @return [Boolean] необходимость использовать SSL/TLS
      def smpt_log?
        false
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Smtp
      #
      # @return [String] пустая строка
      def authentication
        ''
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Smtp
      #
      # @return [String] пустая строка
      def password
        ''
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Sendmail
      #
      # @return [String] пустая строка
      def sendmail_location
        ''
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Sendmail
      #
      # @return [String] пустая строка
      def sendmail_arguments
        ''
      end


      private



      def set_check_config_state(state, message) # :nodoc:
        @is_valid = state
        @config_fail_message = message
        state
      end

      def build_rfc822_name(to, name) # :nodoc:
        return to if name.nil? || name == ''
        "#{name} <#{to}>"
      end

      def processing_to(to, name, message) # :nodoc:
        if to.is_a?(::Array)
          # Несколько адресов
          to.each do |one|
            message.add_to(one, '')
          end
        else
          # Один адрес
          message.add_to(to, name)
        end
      end

    end
  end
end