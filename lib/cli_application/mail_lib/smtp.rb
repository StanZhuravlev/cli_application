# CliApplication::MailLib::Smtp - класс отправки электронной почты через SMTP

module CliApplication
  module MailLib
    class SMTP < ::CliApplication::MailLib::Base

      def initialize(config, folders)
        @delivery_method = :smtp
        super(config, folders)

        check_config
        init_smtp_config
      end

      # Функция всегда возвращает false
      #
      # @param [String] to электронная почта лица, которому отправляется сообщение
      # @param [String] name имя клиента, которому отправляется сообщение
      # @param [String] title заголовок письма
      # @param [String] body текст письма
      # @return [Boolean] true, если письмо отправлено
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
        rescue Errno::ECONNREFUSED
          $stderr.puts "Почтовый сервер #{@smtp_config[:address]}:#{@smtp_config[:port]} не найден"
          false
        rescue Exception => e
          $stderr.puts "Ошибка отправки письма: #{e.message}"
          false
        end
      end

      def address
        @smtp_config[:address]
      end

      def domain
        @smtp_config[:domain]
      end

      def port
        @smtp_config[:port]
      end

      def tls?
        @smtp_config[:tls]
      end

      def smtp_log?
        @smtp_config[:smtp_log]
      end

      def authentication
        @smtp_config[:authentication]
      end

      def user_name
        @smtp_config[:user_name]
      end

      def password
        @smtp_config[:password]
      end


      private


      def send_message(message)
        message.clear_bcc(true)

        smtp = Net::SMTP.new(address, port)
        if tls?
          smtp.enable_tls(OpenSSL::SSL::VERIFY_NONE)
        end
        smtp.set_debug_output $stderr if smtp_log?
        if user_name == ''
          smtp.start(domain) do |mailer|
            mailer.send_message message.to_s, message.from_email, message.to_emails
          end
        else
          smtp.start(domain, user_name, password, authentication) do |mailer|
            mailer.send_message message.to_s, message.from_email, message.to_emails
          end
        end

      end


      def check_config
        return set_check_config_state(false, "Не найдена секция конфиг-файла cli/mail/smtp") if @config.smtp.nil?
        return set_check_config_state(false, "Не найден параметр конфиг-файла cli/mail/smtp/address") if @config.smtp.address.nil?
        return set_check_config_state(false, "Параметр конфиг-файла cli/mail/smtp/address не должен быть пуст") if @config.smtp.address == ''
        return set_check_config_state(false, "Не найден параметр конфиг-файла cli/mail/smtp/domain") if @config.smtp.domain.nil?
        return set_check_config_state(false, "Параметр конфиг-файла cli/mail/smtp/domain не должен быть пуст") if @config.smtp.domain == ''
        return set_check_config_state(false, "Не найден параметр конфиг-файла cli/mail/smtp/port") if @config.smtp.port.nil?
        return set_check_config_state(false, "Параметр конфиг-файла cli/mail/smtp/port не должен быть пуст") if @config.smtp.port == ''

        set_check_config_state(true, '')
      end

      def init_smtp_config
        @smtp_config = Hash.new
        @smtp_config[:domain] = @config.smtp.domain || ''
        @smtp_config[:address] = @config.smtp.address || ''
        @smtp_config[:port] = @config.smtp.port || ''
        @smtp_config[:tls] = @config.smtp.tls
        @smtp_config[:smtp_log] = @config.smtp.debug
        @smtp_config[:authentication] = (@config.smtp.authentication || '').to_sym
        @smtp_config[:user_name] = @config.smtp.user_name || ''
        @smtp_config[:password] = @config.smtp.password || ''
      end

    end
  end
end