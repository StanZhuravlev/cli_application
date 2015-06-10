#!/usr/bin/env ruby
#encoding: utf-8
require '../class/cli_example.rb'

class TestValid < CliExample

  def main

    if mail.valid?
      puts "Выбран способ отправки почты: #{mail.delivery_method}"
    else
      $stderr.puts mail.config_fail_message
    end

    return 0
  end

end

app = TestValid.new(ARGV, __dir__)

app.version = '1.0'
app.releasedate = '2015-06-09'
app.shortdescription = 'Проверяем настройки почтовой подсистемы'
app.description = "Класс CliApplication\n#{app.shortdescription}"

app.help

app.run
exit(app.exitcode)

