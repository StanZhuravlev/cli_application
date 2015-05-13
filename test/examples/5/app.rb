#!/usr/bin/env ruby
#encoding: utf-8
require '../1/cli_example.rb'

class TestApp < CliExample

  def main
    puts "Временная зона для приложения (из конфига класса): #{config.cli.timezone}"
    puts "Тестовый ключ (из доп. конфига приложения): #{config.this_app.test_key}"
    puts
    0
  end

  def init_app
    super
    @config.add('app_config.yml', :app)
  end

end

app = TestApp.new(ARGV, __dir__)

app.version = '1.0'
app.releasedate = '2015-05-11'
app.shortdescription = 'Пример 4 - Различные параметры командной строки'
app.description = "CliApplication gem демо. #{app.shortdescription}"

app.help
app.footer = "{status} ({exitcode}) - приложение завершено за {executed_at} секунд (занято в памяти {memory})"

app.run
exit(app.exitcode)

