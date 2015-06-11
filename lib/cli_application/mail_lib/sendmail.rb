# CliApplication::MailLib::Sendmail - класс отправки электронной почты через Sendmail

module CliApplication
  module MailLib
    class Sendmail < ::CliApplication::MailLib::Base

      def initialize(config, folders) # :nodoc:
        @delivery_method = :sendmail
        super(config, folders)

        check_config
      end

      # Метод отправки электронного сообщения через sendmail
      #
      # @param [String] to электронная почта лица, которому отправляется сообщение, или массив адресов
      # @param [String] name имя клиента, которому отправляется сообщение
      # @param [String] title заголовок письма
      # @param [String] body текст письма
      # @return [Boolean] true, если письмо помещено в очередь сообщений sendmail
      def simple_send(to, name, title, body)
        return false unless valid?

        message = CliApplication::MailLib::Message.new
        message.from_email = @config.from
        message.subject = title
        message.body = (@config.footer.nil? || @config.footer == '') ? body : (body+@config.footer)
        processing_to(to, name, message)

        begin
          send_message(message)
          true
        rescue Exception => e
          $stderr.puts "Ошибка отправки письма: #{e.message}"
          false
        end
      end

      # Метод возвращает путь к скрипту 'sendmail'
      #
      # @return [String] путь к скрипту 'sendmail'
      def sendmail_location
        @config.sendmail.location
      end

      # Метод возаращает опции 'sendmail'
      #
      # @return [String] опции 'sendmail'
      def sendmail_arguments
        @config.sendmail.arguments
      end


      private



      def send_message(message) # :nodoc:
        # Дополнительная информация по использованию sendmail:
        #   http://blog.antage.name/posts/sendmail-in-rails.html

        cmdline = Array.new
        cmdline << "echo \"#{'rrrrr' + message.to_s}\""
        cmdline << '|'
        cmdline << sendmail_location
        cmdline << sendmail_arguments
        cmdline << '2>&1'
        cmdline = cmdline.join(' ')

        output = `#{cmdline}`
        res = $?.exitstatus

        if res != 0
          raise "SendmailError_#{res}"
        end
      end

      def check_config # :nodoc:
        return set_check_config_state(false, "Не найдена секция конфиг-файла cli/mail/sendmail") if @config.sendmail.nil?
        return set_check_config_state(false, "Не найден параметр конфиг-файла cli/mail/sendmail/location") if @config.sendmail.location.nil?
        return set_check_config_state(false, "Не найден параметр конфиг-файла cli/mail/sendmail/arguments") if @config.sendmail.arguments.nil?
        return set_check_config_state(false, "Не найден sendmail (#{@config.sendmail.location.inspect})") unless File.exist?(@config.sendmail.location)

        set_check_config_state(true, '')
      end

    end
  end
end
