#!/usr/bin/env ruby
#encoding: utf-8
require './cli_example.rb'

class TestApp < CliExample

  def main
    # Внутри класса можно получать папки приложения или базового класса
    # что эквивалентно __FILE__, но более удобно
    puts "Приложение запущено из папки: #{self.folder.inspect}"
    puts "Базовый класс расположен: #{self.folder(:class).inspect}"

    # В базовом классе CliExample добавлена необязательная функция init_app
    # в которой осуществляется подгрузка дополнительного конфига класса
    puts @config.config.inspect
    puts "Значение из доп. конфига класса: #{@config.config[:common][:test_key]}"

    # В этот класс TestApp добавлена необязательная функция init_app
    # в которой осуществляется подгрузка дополнительного конфига приложения
    puts "Значение из доп. конфига приложения: #{@config.config[:app][:test_key]}"

    puts "! Число конфигов неограничено"

    # todo: progress_bar и методы st_tools

    puts
    puts "--- Часть 2 - ActiveRecords ------------------"
    tc = Tovar.first
    puts tc.inspect


    puts
    return 0
  end

  def init_app
    super
    add_config('app_config.yml', :app)
  end

end

app = TestApp.new(ARGV, __dir__)

app.version = '1.0'
app.releasedate = '2015-04-28'
app.shortdescription = 'Тестовое приложение'
app.description = "CliApplication gem. #{app.shortdescription}"

app.set_argv(:donwcase, 'do', 'none', 'Начать исполнение действий')
app.set_argv(:range, 'user_id', '53,124', 'Массив идентификаторов пользователей')
app.set_argv(:range, 'empty', '', 'Массив пустых значений. Массив пустых значений. Массив пустых значений. Массив пустых значений. ')
app.set_argv(:boolean, 'debug', 'false', 'Начать отладку. Начать отладку. Начать отладку. Начать отладку. Начать отладку. Начать отладку. Начать отладку. Начать отладку. Начать отладку. Начать отладку. Начать отладку. Начать отладку. Начать отладку. Начать отладку. Начать отладку. ')
app.set_argv(:upcase, 'city', 'Нет', 'Город для анализа')

app.help

app.run
exit(app.exitcode)

