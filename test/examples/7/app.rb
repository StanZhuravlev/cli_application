#!/usr/bin/env ruby
#encoding: utf-8
require '../1/cli_example.rb'

class TestApp < CliExample

  def main
    puts "Почта доступна?: #{mail.valid?.inspect}"
    if mail.valid?
      puts "Способ отправки почты: #{mail.delivery_method}"
      case mail.delivery_method
        when :log
          puts "Почта сохраняется в лог-файл: #{mail.log_filename.inspect}"
        when :sendmail
          puts "sendmail расположен в: #{mail.sendmail_location.inspect}"
        when :smtp
          puts "Почтовый сервер: #{mail.address}:#{mail.port}"
        else
          puts "Неизвестная конфигурация (данной ветки не должно быть)"
      end
    else
      puts "Ошибка доступа к почте: #{mail.config_fail_message}"
    end


    text = Array.new
    text << "<h1>Привет</h1>"
    text << "<p>Я знаю три фрукта:</p>"
    text << "<ul>"
    text << "<li>яблоко</li>"
    text << "<li>груша</li>"
    text << "<li>апельсин (<strong>любимый фрукт!</strong>)</li>"
    text << "</ul>"
    text << "<hr width='1px'>"

    mail.simple_send('user@host.ru', 'User Name', 'Тестовый заголовок', text.join("\n"))
  end

end

app = TestApp.new(ARGV, __dir__)

app.version = '1.0'
app.releasedate = '2015-05-11'
app.shortdescription = 'Пример 7 - Отправка почты'
app.description = "CliApplication gem демо. #{app.shortdescription}"

app.help

app.run
exit(app.exitcode)

