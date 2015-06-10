require '../../lib/cli_application.rb'

class CliExample < CliApplication::App

  def initialize(argv, folder, lang = :ru)
    super(argv, folder, __dir__, lang)
  end

  # Для примеров admin_mailer
  def simple_send(to, name, title, body)
    if mail.valid?
      mail.simple_send(to, name, title, body)
    else
      $stderr.puts "Ошибка отправки письма: #{mail.config_fail_message}"
    end
  end

end
