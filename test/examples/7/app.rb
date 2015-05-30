#!/usr/bin/env ruby
#encoding: utf-8
require '../1/cli_example.rb'

class TestApp < CliExample

  def main
    puts "Почта доступна?: #{mail.valid?.inspect}"
    puts "Почтовый сервер: #{mail.host}:#{mail.port}"

    mail.quick_send('stan@test-mail.ru', 'Stan', 'Тестовый заголовок', 'Hellow, world')
  end

end

app = TestApp.new(ARGV, __dir__)

app.version = '1.0'
app.releasedate = '2015-05-11'
app.shortdescription = 'Пример 2 - Настройки CLI-приложения'
app.description = "CliApplication gem демо. #{app.shortdescription}"

app.help

app.run
exit(app.exitcode)

