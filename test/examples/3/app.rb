#!/usr/bin/env ruby
#encoding: utf-8
require '../1/cli_example.rb'

class TestApp < CliExample

  def main
    return 10
  end

end

app = TestApp.new(ARGV, __dir__)

app.version = '1.0'
app.releasedate = '2015-05-11'
app.shortdescription = 'Пример 3 - Настройка футера'
app.description = "CliApplication gem демо. #{app.shortdescription}"

app.help
app.footer = "{status} ({exitcode}) - приложение завершено за {executed_at} секунд (занято в памяти {memory})"

app.run
exit(app.exitcode)

