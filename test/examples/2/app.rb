#!/usr/bin/env ruby
#encoding: utf-8
require '../1/cli_example.rb'

class TestApp < CliExample

  def main
    puts "Приложение: #{exename}"
    puts "Запущено из папки: #{folders[:app]}"
    puts "Базовый клас в: #{folders[:class]}"
    puts "Занимает сейчас в памяти #{StTools::Human.memory}"
    puts "С момента начала выполнения прошло #{executed_at} секунд"
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

