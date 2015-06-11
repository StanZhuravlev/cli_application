#!/usr/bin/env ruby
#encoding: utf-8
require '../class/cli_example.rb'

$message_body = "<h1>Уведомление</h1>
<p>Получены следующие алерты</p>
<ul>
<li>Не хватает памяти</li>
<li>Перегрузка процессора</li>
<li>Неисправен HDD</li>
</ul>
<p>Необходимо <b>срочно</b> принять меры!</p>"

class TestValid < CliExample

  def main

    simple_send('user@host.ru', 'User Name', 'Тестовое письмо', $message_body)

    return 0
  end

end

app = TestValid.new(ARGV, __dir__)

app.version = '1.0'
app.releasedate = '2015-06-09'
app.shortdescription = 'Проверяем подсистему почтовых сообщений'
app.description = "Класс CliApplication\n#{app.shortdescription}"

app.help

app.run
exit(app.exitcode)

