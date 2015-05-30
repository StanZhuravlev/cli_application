# CliApplication::Mail - отсылка сообщений администратору системы
# может быть использован для отсылки критических сообщений

module CliApplication
  class Mail

    # Инициализация методов, позволяющих рассылать письма адимнистраторам
    # системы
    def initialize(config)
      @config = config
      if !@config.nil? && @config.enable
        @is_valid = true
      else
        @is_valid = false
      end
    end

    # Метод показывает готовность подсистемы отсылки почты администратору
    # @return [Boolean] true, если разрешено отправлять письма администратору
    def valid?
      @is_valid
    end

    # Функция отправляет сообщение по электронной почте
    # @param [String] to электронная почта лица, которому отправляется сообщение
    # @param [String] name имя клиента, которому отправляется сообщение
    # @param [String] title заголовок письма
    # @param [String] body текст письма
    # @return [Boolean] true, если письмо отправлено
    def quick_send(to, name, title, body)
      return false unless valid?

      to_email = (name.nil? || name == '') ? to : "#{name} <#{to}>"
      body_full = (@config.footer.nil? || @config.footer == '') ? body : (body+@config.footer)

      begin
        send_message(to_email, title, body_full)
        true
      rescue Errno::ECONNREFUSED
        puts "Почтовый сервер не найден, выводим почтовое сообщение в консоль"
        puts "From: #{@config.from.inspect}"
        puts "To: #{to_email.inspect}"
        puts "Title: #{title.inspect}"
        puts "Body: #{(body_full[0,256] + '...').inspect}"
        false
      rescue Exception => e
        puts "Ошибка отправки письма: #{e.message}"
        false
      end
    end

    def send_message(to, title, body)
      msgstr = <<MESSAGE_END
From: #{@config.from}
To: #{to}
Subject: #{title}
Date: #{::Time.zone.now.to_formatted_s(:rfc822) }
MIME-Version: 1.0
Content-type: text/html

#{body}
MESSAGE_END

      Net::SMTP.start(host, port) do |smtp|
        smtp.send_message msgstr, @config.from, to
      end
    end

    def host
      @config.host || 'none'
    end

    def port
      @config.port || 0
    end

  end
end

