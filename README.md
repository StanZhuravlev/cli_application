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
на следующей иерархии классов: ```ruby CliApplication -> YouCliClass -> YouCliApplication```.

В данной иерархии обеспечивается:

- на уровне CliApplication - поддержка управления аргументами командной строки, ведение статистики по вызовам приложения.
- на уровне YouCliClass - поддержка управления конфигами, общими функциями и данными приложений.
- на уровне YouCliApplication - выполнение логики скрипта.

Быстрота разработки обеспечивается:

1. Возможность писать свой конфиг (как на уровне класса, так и на уровне приложения), но добавлять его в единый механизм чтения конфигов CliApplication
2. Возможность удобно манипуляировать аргументами командной строки, включая различные преобразования (например, см. http://www.rubydoc.info/gems/st_tools/0.3.5/StTools/Module/String#to_range-instance_method)
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

# Зависимости

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
  tz: "Moscow"
  active_record_tz: "Moscow"
```

И создаем своё тестовое приложение

```ruby
#!/usr/bin/env ruby
#encoding: utf-8
require './cli_example.rb'

class TestApp < CliExample

  def main
    puts "Hello, #{argv[:user]}!"
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


## Contributing

1. Fork it ( https://github.com/[my-github-username]/cli_application/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
