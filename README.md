# CliApplication

Библиотека CliApplication предназначена для построения CLI-приложений. В процессе работы над различым ПО Backoffice,
приходиться регулярно сталкиваться с задачами создания т.н. "фоновых скриптов", которые выполняют различные операции:

- готовят данные для выдачи абоненту
- парсят другие сайты
- получают различную информацию от внешних систем

Использовать для этого разработку REST-методов в рамках стандартной модели Rails накладно по ряду причин - проще для
этого разработать отдельные скрипты и вызывать их через cron как любой другой bash-скрипт. Библиотека предназначена как раз
для создания таких приложений, взаимодействие с которыми идет через командную строку. При этом библиотека обеспечивает
крайне быструю и удобную разработку таких приложений.

CLI-приложения, написанные на базе библиотеки CliApplication, представляют собой трех-уровеную структуру, базирующуюся
на следующей иерархии классов: `CliApplication -> YouCliClass -> YouCliApplication`.

В данной иерархии обеспечивается:

- на уровне CliApplication - поддержка управления аргументами командной строки, ведение статистики по вызовам приложения.
- на уровне YouCliClass - поддержка управления конфигами, общими функциями и данными приложений.
- на уровне YouCliApplication - выполнение логики скрипта.

Быстрота разработки обеспечивается:

1. Возможность писать свой конфиг (как на уровне класса, так и на уровне приложения), но добавлять его в единый механизм чтения конфигов CliApplication
2. Возможность удобно манипуляировать аргументами командной строки, включая различные преобразования (например, см. [здесь](http://www.rubydoc.info/gems/st_tools/0.3.5/StTools/Module/String#to_range-instance_method))
3. Подключение ко всем необходимым базам данных, заданных в конфигах
4. Наличием готовых функций формирования статистики для постанализа статуса запуска приложений.
4. Переиспользованием моделей ActiveRecord Rails-приложения для единообразного управления запиями баз данных.

## Установка

Добавить в Gemfile:

```ruby
gem 'cli_application'
```

Установить гем cредствами Bundler:

    $ bundle

Или установить его отдельно:

    $ gem install cli_application

## Зависимости

Для работы гема требуется Ruby не младше версии 2.2.1. Также для работы необходим гем StTools (https://github.com/StanZhuravlev/st_tools).

## Использование

Использование библиотеки проще всего показать на базе примеров. Все примеры доступны в папке /test/examples

### Пример 1 - по традиции, Hello, World (или не World)

_См. /test/examples/1_

Сначала создадим класс ```ruby CliExample```, который станет основной для CLI-приложений в конкретном проекте.

```ruby
require 'cli_application'

class CliExample < CliApplication::App

  def initialize(argv, folder, lang = :ru)
    super(argv, folder, __dir__, lang)
  end

  def init_app
    super
    add_config('config.yml', :class)
  end

end
```

Затем формируем минимальный конфиг, который включает настройки времени.

```yaml
cli:
  timezone: "Moscow"
```

И создаем своё тестовое приложение

```ruby
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
```

Результатом работы данного скрипта при запуске без каких либо параметров будет следующий вывод:

```text
app.rb - Пример 1 - Hello, world
Версия 1.0 (2015-05-11)
Ранее не запускалось
Всего было 1 запусков

CliApplication gem демо. Пример 1 - Hello, world

Параметры приложения:
  user - Имя того, кого приветствуем (по умолчанию "World":String)


Hello, World!
```

Как видим, при запуске скрипта сразу был выведен текст подсказки, включая описание параметров командной строки
с указанием значения по умолчанию. Самое значение по умолчанию оказалось в переменной argv (```ruby argv[:user] ```).

Теперь запустим приложение ```text app.rb user=Egor```. Получим следующий вывод.

```text
app.rb - Пример 1 - Hello, world
Версия 1.0 (2015-05-11)
Последний запуск: 11 мая 2015 г. 19:14:46 (21 минута 12 секунд назад)
Всего было 2 запусков

CliApplication gem демо. Пример 1 - Hello, world

Параметры приложения:
  user - Имя того, кого приветствуем (по умолчанию "World":String)


Hello, Egor!
```

При этом выводится информация о дате и времени предыдущего запуска приложений. Эта информация хранится в папке stat,
автоматически создаваемой в той же папке, где находится класс CliExample. В нашем случае, в папке создан файл app.yml
следующего содержания.

```yaml
---
:name: app.rb
:shortdescription: "Пример 1 - Hello, world"
:version: '1.0'
:releasedate: '2015-05-11'
:timezone: Moscow
:last_started_at: '2015-05-11 19:35:58 +0300'
:folders:
  :app: "/Users/Stan/Documents/Development/cli_application/test/examples/1"
  :class: "/Users/Stan/Documents/Development/cli_application/test/examples/1"
  :stat: "/Users/Stan/Documents/Development/cli_application/test/examples/1/stat"
:avg:
  :starts: 3
  :executed_at: 0.020647
  :executed_at_human: 0.020647 секунд
  :memory: 32126
:last:
  :started_at: '2015-05-11 19:35:58 +0300'
  :executed_at: 0.031052
  :executed_at_human: 0.031052 секунд
  :memory: 32 кбайт
  :exitcode: 255
:last10:
- 2015-05-11 19:35:58 +0300,255,0.031052,32 кбайт
- 2015-05-11 19:14:46 +0300,255,0.030889,31 кбайт
```

Данный файл содержит статистическую информацию относительно запусков приложения, включая среднее время исполнения,
объем задействованной памяти и прочее.

### Пример 2 - Различные параметры приложения

_См. /test/examples/2_

Второй пример показывает набор данных, которые можно получить внутри приложения. Для этого полностью заменим функцию
`main` из предыдущего примера на следующую...

```ruby
def main
  puts "Приложение: #{exename}"
  puts "Запущено из папки: #{folders[:app]}"
  puts "Базовый класс в: #{folders[:class]}"
  puts "Занимает сейчас в памяти #{StTools::Human.memory}"
  puts "С момента начала выполнения прошло #{executed_at} секунд"
end
```
...и посмотрим на результат запуска приложения.

```text
Приложение: app.rb
Запущено из папки: /Users/Stan/Documents/Development/cli_application/test/examples/2
Базовый клас в: /Users/Stan/Documents/Development/cli_application/test/examples/1
Занимает сейчас в памяти 31 кбайт
С момента начала выполнения прошло 0.055399 секунд
```
Показатель `executed_at` - время в секундах с момента старта приложения. Это может быть важно для фиксации
продолжительности работы скрипта.

Объект `folders` содержит список папок различных частей приложения. Наиболее важны два типа папок, `folders[:class]`
возвращает папку, в которой находится базовый класс всех приложений одного проекта. Может быть использована, например,
для записи логов каждого приложения в единое место (по аналогии с файлом статистики). Вторая папка `folders[:app]`
возвращает папку, из которой запущено приложение.

### Пример 3 - Футер

_См. /test/examples/3_

Для добавления в конце работы приложения футера с итогом работы приложения можно использовать параметр `app.footer`.
Данный параметр поддерживает переменные, которые в конце исполнения приложения заменятся на результаты работы приложения.

Сделаем следующую функцию `main`.

```ruby
  def main
    return 0
  end
```

И добавим перед вызовом `run` функцию `footer`.

```ruby
app.help
app.footer = "{status} ({exitcode}) - приложение завершено за {executed_at} секунд (занято в памяти {memory})"
app.run
```

Запустим приложение.

```text
SUCCESS (0) - приложение завершено за 0.033943 секунд (занято в памяти 32 кбайт)
```

Заменим в функции `main` выражение `return 0` на `return 10`, и запустим приложение вновь

```text
FAIL (10) - приложение завершено за 0.046153 секунд (занято в памяти 30 кбайт)
```
Если нужно отключить футер в процессе выполнения приложения, необходимо внутри функции `main` выполнить `footer = nil`.
Также футер можно изменить в функции `main` в любой момент на другой.

Переменные шаблонизатора представлены в следующей таблице

|Параметр|Значение|
|--------|--------|
|executed_at|Число секунд с момента начала работы приложения|
|memory|Объем паямти, занятой приложением в human-виде|
|status|SUCCESS если exitcode равно нулю, и FAIL в других случаях|
|exitcode|Код, который приложение вернет в bash-среду. Соответствует значению от 0 до 255, возвращаемому из функции `main`|


### Пример 4 - Форматирование параметров командной строки

_См. /test/examples/4_

Рассмотрим ситуацию, когда в CLI-скрипт необходимо передвать большое количество различных параметров, причем на выходе
желатлеьно иметь данные, пригодные к машиной обработке. Для этого существует возможность задавать параметры командной строки
с указаним различных преобразований, которые должны быть проведены над данными. Рассмотрим это на примере.

Добавим перед функцией `app.help` следующий код

```ruby
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
```

...и напишем следующую функцию `main`.

```ruby
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
```

Запустим приложение. Для изменения значений по умочланию запустим следующим образом: `app.rb ex1=value ex2='val value' ex3=1,23,4`.

```text
app.rb - Пример 4 - Различные параметры командной строки
Версия 1.0 (2015-05-11)
Последний запуск: 12 мая 2015 г. 13:57:44 (4 минуты 20 секунд назад)
Всего было 29 запусков

CliApplication gem демо. Пример 4 - Различные параметры командной строки

Параметры приложения:
  ex1  - Пример преобразования аргумента в нижний регистр (по умолчанию "НИКолай":String)
  ex2  - Пример преобразования аргумента в верхний регистр (по умолчанию "НИКолай":String)
  ex3  - Пример преобразования логического аргумента в тип boolean (по умолчанию true:TrueClass)
  ex4  - Пример преобразования входного списка в массив (по умолчанию "Москва,Санкт-Петербург,Абакан
         ":Array)
  ex5  - Пример преобразования диапазона в массив (по умолчанию "1, 35, 23, 10-14":Array)
  ex6  - Пример числа с плавающей запятой (по умолчанию 3.14:Float)
  ex7  - Пример целого числа (по умолчанию 3.14:Fixnum)
  ex8  - Пример нормализации строки (по умолчанию "Москва -     крупный город   ":String)
  ex9  - Пример перевода строки в красивый human-вид (по умолчанию "иванов иВАН иваныч":String)
  ex10 - Пример неизменного аргумента командной строки (по умолчанию "ПрИвВеТ":String)


:downcase - "николай" (String)
:upcase - "НИКОЛАЙ" (String)
:bool - true (TrueClass)
:split - ["Абакан", "Москва", "Санкт-Петербург"] (Array)
:range - [1, 10, 11, 12, 13, 14, 23, 35] (Array)
:float - 3.14 (Float)
:integer - 3 (Fixnum)
:normalize - "москва - крупный город" (String)
:caps - "Иванов Иван Иваныч" (String)
:string - "ПрИвВеТ" (String)

SUCCESS (0) - приложение завершено за 0.041796 секунд (занято в памяти 30 кбайт)
```

Мы видим, что все параметры командной строки показаны в виде подсказок при запуске приложения.
При этом они оформлены "красиво" с учетом отступов, с указанием значений по умолчанию.
Допустимы следующие типы преобразований.

|Преобразование|Описание|
|---------|---------|
|:string|Строка передается в приложение, как есть, без модификаций|
|:bool или :boolean|Исходная строка преобразуется в `true` или `false` в соответствии с правилами, описанными [здесь](http://www.rubydoc.info/gems/st_tools/0.3.5/StTools/String#to_bool-class_method).|
|:downcase|Строка приводится к нижнему регистру, как описано [здесь](http://www.rubydoc.info/gems/st_tools/0.3.5/StTools/String#downcase-class_method).|
|:upcase|Строка приводится к верхнему регистру, как описано [здесь](http://www.rubydoc.info/gems/st_tools/0.3.5/StTools/String#upcase-class_method).|
|:normalize|Строка нормализуется для машинной обработки, как описано [здесь](http://www.rubydoc.info/gems/st_tools/0.3.5/StTools/String#normalize-class_method).|
|:caps|Первая буква каждого слова отделенного пробелом или дефисом, приводится к верхнему регистру, остальный - к нижнему (см. [здесь](http://www.rubydoc.info/gems/st_tools/0.3.5/StTools/String#caps-class_method)).|
|:split|Строка делится на массив элементов, разделенных запятыми. Значения сортируются по возрастанию.|
|:range|Строка вида '3,4,10-20' преобразуется в массив значений. Подробнее [здесь](http://www.rubydoc.info/gems/st_tools/0.3.5/StTools/String#to_range-class_method).|
|:range_no_uniq|Аналогично предыдущему, но над массивом не проводится операция `uniq`.|
|:float|Значение введенной строки переводится в float.|
|:integer|Значение введенной строки переводится в целое число.|

### Пример 5 - Подключение дополнительных конфигов

_См. /test/examples/5_

В приложениях можно подключать сколько угодно дополнительных конфигов. Для этого в текст базового класса, или в текст
конкретного приложения, нужно добавить функцию `init_app` следующего содержания. В нашем случае, добавим эту функцию в класс
тестового приложения.

```ruby
def init_app
  super
  @config.add('app_config.yml', :app)
end
```

Сам конфиг сделаем таким

```yaml
this_app:
  test_key: "Hello, world!"
```

Функцию `main` сделаем такой.

```ruby
def main
  puts "Временная зона для приложения (из конфига класса): #{config.cli.timezone}"
  puts "Тестовый ключ (из доп. конфига приложения): #{config.this_app.test_key}"
  puts
  0
end
```

Запустим приложение, посомтрим, что оно выводит.

```text
Временная зона для приложения (из конфига класса): Moscow
Тестовый ключ (из доп. конфига приложения): Hello, world!
```
Таким образом, видно, что после добавления нового конфига, мы смогли внутри приложения обращаться "прозрачно"
как к данным конфига класса, так и к данным нового конфига.

Разберем подробнее.

Мы создали конфиг `app_config.yml`, указав в нем корневой ключ - `this_app`. Данный ключ может быть любым кроме `cli`,
который зарезервирован за конфигом класса (см. пример 1) (без указания временной зоны приложение будет завершаться ошибкой).
При заведении класса в приложение нужно указать его тип - `:app`. Допустимы два типа конфига: `:class` и `:app`. Допустимо
добавлять сколько угодно конфигов с указанием `:class` или `:app`.

При запуске функции `@config.add_config` происходит перечитывание всех конфигов.

Затем в функции `main` осуществляется использование данных конфига с использованием имеющихся в конфиге ключей.

### Пример 6 - Подключение баз данных и моделей ActiveRecord's

_См. /test/examples/6_

С помощью класса CliApplication можно эффективно управлять соединениями с базами данных, и моделями ActiveRecords.
Давайте представим, что мы сделали Rails-проект, определили там модели ActiveRecord, и теперь хотим их переиспользовать
в CLI-приложении. Для этого сделаем следующее.

Сначала пропишем в конфиге параметры подключения к базам данных. Характеристики должны быть в ключе `config.cli.databases`.
Данный ключ должен содержать записи вида <имя конфигурации> => <параметры конфигурации>. Баз данных можно подключать неограниченно.
Рассмотрим пример конфига для подключения к MySQL. Имя конфигурации - `default`.

```yaml
cli:
  timezone: "Moscow"

  databases:
    default:
      adapter: mysql2
      host: localhost
      database: online_store
      username: usersql
      password: password_chars
```

Затем создадим функцию `app.init_active_records`, в которой будем подключать модели. Покажем ее вместе с функцией `main`.

```ruby
def main
  puts Offer.first.inspect
  puts
  0
end

def init_active_records
 require './offer.rb'
end
```

Сама модель (файл offer.rb) должна выглядеть как показано ниже.

```ruby
class Offer < ActiveRecord::Base
  self.establish_connection self.configurations[:default]
  self.table_name = "offers_table"
end
```
Запустим приложение, посомтрим на результат

```text
#<Offer id: 10, category: 1, name: "Игрушка десткая", description: "Эта игрушка непременно понравится...", ...
```

Таким образом, буквально в несколько строк мы можем работать с базами данных в CLI-приложении, так же, как в привычном
Rails-окружении.

### Пример 7 - Отправка электронной почты

_См. /test/examples/7_

Иногда нужно отправлять различные нотификации из скрипта. Для этого классе CliApplication есть почтовый дивжок mail.
Попробуем использовать его

Сначала пропишем в конфиге параметры подключения к почтовой системе. Имя конфигуарции - `cli/mail`.

```yaml
cli:
  timezone: "Moscow"

  mail:
    enable: true
    from: 'Admin <admin@test-mail.ru>'
    host: test-mail.ru
    port: 25
    footer: '<br><br>--------------<br>Your gem <b>cli_application</b>'
```

Допустимые ключи:
* `enable` - если true, то допускается отправка сообщений. Через эту опцию можно запретить отправку
* `from` - адрес почты, с которой будет отправлено сообщение
* `host` - SMPT-сервер. Пока имеется ограничение - использование должно быть без пароля
* `port` - IP-порт почтового сервера
* `footer` - Подпись сообщения

Затем отправим письмо.

```ruby
def main
  mail.quick_send('stan@test-mail.ru', 'Stan', 'Тестовый заголовок', 'Hellow, world')
  0
end
```

В итоге получим.

```html
Hellow, world

--------------
Your gem <b>cli_application</b>
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/cli_application/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
