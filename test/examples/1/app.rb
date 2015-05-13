#!/usr/bin/env ruby
#encoding: utf-8
require './cli_example.rb'

class TestApp < CliExample

  def main
    puts "Hello, #{argv.user}!"
  end

end

app = TestApp.new(ARGV, __dir__)

app.version = '1.0'
app.releasedate = '2015-05-11'
app.shortdescription = 'Пример 1 - Hello, world'
app.description = "CliApplication gem демо. #{app.shortdescription}"

app.set_argv(:string, 'user', 'World', 'Имя того, кого приветствуем')

app.help

app.run
exit(app.exitcode)

