#!/usr/bin/env ruby
#encoding: utf-8
require '../1/cli_example.rb'

class TestApp < CliExample

  def main
    puts ":downcase - #{argv.ex1.inspect} (#{argv.ex1.class.to_s})"
    puts ":upcase - #{argv.ex2.inspect} (#{argv.ex2.class.to_s})"
    puts ":bool - #{argv.ex3.inspect} (#{argv.ex3.class.to_s})"
    puts ":split - #{argv.ex4.inspect} (#{argv.ex4.class.to_s})"
    puts ":range - #{argv.ex5.inspect} (#{argv.ex5.class.to_s})"
    puts ":float - #{argv.ex6.inspect} (#{argv.ex6.class.to_s})"
    puts ":integer - #{argv.ex7.inspect} (#{argv.ex7.class.to_s})"
    puts ":normalize - #{argv.ex8.inspect} (#{argv.ex8.class.to_s})"
    puts ":caps - #{argv.ex9.inspect} (#{argv.ex9.class.to_s})"
    puts ":string - #{argv.ex10.inspect} (#{argv.ex10.class.to_s})"
    puts "Неизвестный ключ возвращает nil - #{argv.no_key.inspect}"

    puts
    0
  end

end

app = TestApp.new(ARGV, __dir__)

app.version = '1.0'
app.releasedate = '2015-05-11'
app.shortdescription = 'Пример 4 - Различные параметры командной строки'
app.description = "CliApplication gem демо. #{app.shortdescription}"

app.set_argv(:downcase, 'ex1', 'НИКолай', 'Пример преобразования аргумента в нижний регистр')
app.set_argv(:upcase, 'ex2', 'НИКолай', 'Пример преобразования аргумента в верхний регистр')
app.set_argv(:bool, 'ex3', true, 'Пример преобразования логического аргумента в тип boolean')
app.set_argv(:split, 'ex4', 'Москва,Санкт-Петербург,Абакан', 'Пример преобразования входного списка в массив')
app.set_argv(:range, 'ex5', '1, 35, 23, 10-14', 'Пример преобразования диапазона в массив')
app.set_argv(:float, 'ex6', 3.14, 'Пример числа с плавающей запятой')
app.set_argv(:integer, 'ex7', 3.14, 'Пример целого числа')
app.set_argv(:normalize, 'ex8', 'Москва -     крупный город   ', 'Пример нормализации строки')
app.set_argv(:caps, 'ex9', 'иванов иВАН иваныч', 'Пример перевода строки в красивый human-вид')
app.set_argv(:string, 'ex10', 'ПрИвВеТ', 'Пример неизменного аргумента командной строки')

app.help
app.footer = "{status} ({exitcode}) - приложение завершено за {executed_at} секунд (занято в памяти {memory})"

app.run
exit(app.exitcode)

