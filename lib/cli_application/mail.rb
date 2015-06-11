# CliApplication::Mail - отсылка сообщений администратору системы
# может быть использован для отсылки критических сообщений

module CliApplication
  class Mail # :nodoc:

    # Инициализация методов, позволяющих рассылать письма адимнистраторам
    # системы
    def self.new(config, folders)
      res = self.check(config)

      case res[:delivery_method]
        when :log
          ::CliApplication::MailLib::Log.new(config, folders)
        when :smtp
          ::CliApplication::MailLib::SMTP.new(config, folders)
        when :sendmail
          ::CliApplication::MailLib::Sendmail.new(config, folders)
        else
          ::CliApplication::MailLib::Error.new(config, folders)
      end
    end

    def self.check(config)
      methods = ['log', 'sendmail', 'smtp']

      return self.set_valid_state(false, 'Отсутствует секция mail') if config.nil?
      return self.set_valid_state(false, 'Отсутствует параметр enable в секции mail') if config.enable.nil?
      return self.set_valid_state(false, 'Отсутствует параметр from в секции mail') if config.from.nil?
      return self.set_valid_state(false, 'Параметр from в секции mail не должен быть пустым') if config.from.strip == ''
      warn "Внимание: передача почтовых сообщений отключена" unless config.enable
      return self.set_valid_state(false, "Метод доставки должен быть один из: #{methods.inspect}") unless methods.include?(config.delivery_method.to_s)

      res = Hash.new
      res[:valid] = true
      res[:delivery_method] = config.delivery_method.to_sym
      res[:error_msg] = ''
      res
    end

    def self.set_valid_state(state, error_msg)
      res = Hash.new
      res[:valid] = false
      res[:delivery_method] = :error
      res[:error_msg] = error_msg
      res
    end


  end
end

