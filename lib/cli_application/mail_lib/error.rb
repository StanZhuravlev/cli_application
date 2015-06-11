# CliApplication::MailLib::Log - класс хранения почты в файлы

module CliApplication
  module MailLib
    class Error < ::CliApplication::MailLib::Base

      def initialize(config, folders) # :nodoc:
        @delivery_method = :error
        super(config, folders)
        @is_valid = false

        check_config
      end

      # Функция всегда возвращает false
      #
      # @param [String] to электронная почта лица, которому отправляется сообщение, или массив адресов
      # @param [String] name имя клиента, которому отправляется сообщение
      # @param [String] title заголовок письма
      # @param [String] body текст письма
      # @return [Boolean] false
      def simple_send(to, name, title, body)
        false
      end


      private



      def check_config  # :nodoc:
        methods = ['log', 'sendmail', 'smtp']

        return set_check_config_state(false, "Отсутствует секция mail") if @config.nil?
        return set_check_config_state(false, 'Отсутствует параметр enable в секции mail') if @config.enable.nil?
        return set_check_config_state(false, 'Отсутствует параметр from в секции mail') if @config.from.nil?
        return set_check_config_state(false, 'Параметр from в секции mail не должен быть пустым') if @config.from.strip == ''
        return set_check_config_state(false, "Метод доставки должен быть один из: #{methods.inspect}") unless methods.include?(@config.delivery_method.to_s)

        set_check_config_state(false, 'Неизвестная ошибка (почтовая подсистема)')
      end

    end
  end
end