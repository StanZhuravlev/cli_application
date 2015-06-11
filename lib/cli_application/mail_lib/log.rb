# CliApplication::MailLib::Log - класс хранения почты в файлы

module CliApplication
  module MailLib
    class Log < ::CliApplication::MailLib::Base

      def initialize(config, folders) # :nodoc:
        @delivery_method = :log
        super(config, folders)
        check_config

        prepare_log_filename
      end

      # Данный метод возвращает имя файла для записи логов. В этом методе происходит
      # обработка параметра даты {date}, что позволяет разбивать логи по дням.
      #
      # @return [String] имя лог-файла для записи сообщений
      def log_filename
        @log_filename.gsub('{date}', ::Time.zone.now.to_date.to_s(:db))
      end

      # Функция записывает сообщение электронной почты в лог-файл, с преобразованием HTML-формата в текст
      #
      # @param [String] to электронная почта лица, которому отправляется сообщение, или массив адресов
      # @param [String] name имя клиента, которому отправляется сообщение
      # @param [String] title заголовок письма
      # @param [String] body текст письма
      # @return [Boolean] true, если письмо отправлено
      def simple_send(to, name, title, body)
        message = CliApplication::MailLib::Message.new
        message.from_email = @config.from
        message.subject = title
        message.body = (@config.footer.nil? || @config.footer == '') ? body : (body+@config.footer)

        processing_to(to, name, message)

        out = Array.new
        out << ''
        out << "--- #{StTools::Human.format_time(::Time.zone.now, :full, :full)} -------------------"
        out << message.to_log
        record = out.join("\n")

        open(log_filename, 'a') do |f|
          f.puts record
        end

        true
      rescue Exception => e
        $stderr.puts "Ошибка записи электронного сообщения: #{e.message}"
        false
      end


      private


      def check_config # :nodoc:
        return set_check_config_state(false, "Не найдена секция конфиг-файла cli/mail/log") if @config.log.nil?
        return set_check_config_state(false, "Не найден параметр конфиг-файла cli/mail/log/location") if @config.log.location.nil?
        return set_check_config_state(false, "Параметр конфиг-файла cli/mail/log/location не должен быть пустым") if @config.log.location == ''
        set_check_config_state(true, '')
      end

      def prepare_log_filename # :nodoc:
        return '' unless valid?

        res = @config.log.location
        res.gsub!('{exe}', File.basename(StTools::System.exename, '.rb').gsub(/\_/, '-'))
        res.gsub!('****', @folders[:app])
        res.gsub!('***', @folders[:class])
        @log_filename = res

        path = File.dirname(@log_filename)
        begin
          unless Dir.exist?(path)
            FileUtils.mkdir_p(path)
            FileUtils.chmod(0777, path)
          end
        rescue Exception => e
          $stderr.puts "Ошибка создания папки для записи сообщений электронной почты (#{e.message})"
          $stderr.puts "  #{path}"
          $stderr.puts "  Обратитесь к разработчику данного скрипта"
        end

      end

    end
  end
end