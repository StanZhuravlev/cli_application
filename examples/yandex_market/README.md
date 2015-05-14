# Генератор прайс-листов Yandex.Market за 70 строк кода

Рассмотрим на конкретном примере работу библиотеки CliApplication. Тестовая задача: имеется Интернет-магазин,
необходимо сформировать для него прайс-лист для Яндекс.Маркет. При этом необходимо учитывать, что необходимы разные
прайс-листы для различных прайс-агрегаторов, то есть возможность формировать прайс-листы для отдельных категорий.

Сначала проведем некоторую подготовительную работу. Поставим gem [yml_builder](https://rubygems.org/gems/yml_builder)
предназначенный для генерации прайс-листов в формате Yandex.Market.

```text
gem install yml_builder
```

Затем, создадим тестовый класс `CliExample`, наследованный от `CliApplication`. Поскольку мы не вводим никаких специфических
функций, то базовый класс занимает всего несколько строк.

```ruby
require 'cli_application'

class CliExample < CliApplication::App

  def initialize(argv, folder, lang = :ru)
    super(argv, folder, __dir__, lang)
  end

end
```

Затем, в той же директории, в которой находится базовый класс, разместим конфиг. В качестве тестового хранилища
будем использовать sqllite.

```yml
cli:
  timezone: "Moscow"
  ar_timezone: "Moscow" # Active Record timezone

  databases:
    example:
      adapter: 'sqlite3'
      database: 'example.db'
```

Теперь создадим приложение, которое заполнит базу данных тестовыми данными. Его тоже построим на базе гема
`cli_application`. Запишем файл под именем `build_test_data.rb`.

```ruby
#!/usr/bin/env ruby
#encoding: utf-8
require '../class/cli_example.rb'

class Category < ActiveRecord::Base
  has_many :offer
end

class Offer < ActiveRecord::Base
  belongs_to :category
end

class BuildTestData < CliExample

  def main
    ActiveRecord::Base.logger = Logger.new(STDERR)
    ActiveRecord::Base.establish_connection(databases[:example])

    ActiveRecord::Schema.define do
      drop_table :offers if table_exists? :offers
      drop_table :categories if table_exists? :categories

      create_table :offers do |table|
        table.column :name, :string
        table.column :url, :string
        table.column :description, :string
        table.column :photo, :string
        table.column :category_id, :integer
        table.column :price, :integer
      end

      create_table :categories do |table|
        table.column :title, :string
      end
    end

    category = Category.create(title: 'Игрушки')
    category.offer.create(name: 'Пони', url: 'http://test/pony', description: 'Любимая игрушка для детей', photo: 'http://test/image1', price: 100)
    category.offer.create(name: 'Машинка', url: 'http://test/car', description: 'Любимая игрушка для мальчиков', photo: 'http://test/image2', price: 200)
    category.offer.create(name: 'Кукла', url: 'http://test/toy', description: 'Кукла для девочек', photo: 'http://test/image3', price: 230)

    category = Category.create(title: 'Одежда')
    category.offer.create(name: 'Кофта', url: 'http://test/wear', description: 'Красивая кофта', photo: 'http://test/image4', price: 3100)
    category.offer.create(name: 'Ботинки', url: 'http://test/boots', description: 'Элегантные ботинки', photo: 'http://test/image5', price: 8900)

    0
  end

end

app = BuildTestData.new(ARGV, __dir__)

app.version = '1.0'
app.releasedate = '2015-05-14'
app.shortdescription = 'Подготовка тестовых данных для генерации прайс-листа для Yandex.Market'
app.description = "CliApplication gem демо. #{app.shortdescription}"

app.run
exit(app.exitcode)
```

И, наконец, делаем завершающий шаг, и пишем приложение, формирующее прайс-лист. Запишем его под именем `price.rb`.
Модели таблиц базы данных включены прямо в код данного скрипта, но их можно вынести в отдельные файлы или подключить
модели Rails-проекта. Для этого в классе `GenerateYandexPriceList` необходимо добавить функцию
[init_active_records](http://www.rubydoc.info/gems/cli_application/0.1.1/CliApplication/App:init_active_records).


```ruby
#!/usr/bin/env ruby
#encoding: utf-8
require '../class/cli_example.rb'
require 'yml_builder'

class Category < ActiveRecord::Base
  has_many :offer
end

class Offer < ActiveRecord::Base
  belongs_to :category
end

class GenerateYandexPriceList < CliExample

  def add_category(id)
    unless @price.categories.has?(id)
      one = Category.where(id: id).first
      @price.categories.add(id: one.id, name: one.title)
    end
  end

  def main
    ActiveRecord::Base.establish_connection(databases[:example])

    @price = YmlBuilder::Yml.new
    @price.categories.filter = argv.categories
    @price.shop.name = 'Тестовый магазин'
    @price.shop.company = "ООО 'Рога & Копыта'"
    @price.shop.url = 'http://test'
    @price.shop.email = 'info@test.ru'
    @price.shop.phone = '+7 (495) 123-4567'

    @price.currencies.rub = 1
    @price.local_delivery_cost = 300

    Offer.all.each do |offer|
      one = YmlBuilder::Offer.new('simple')
      one.id = offer.id
      one.name = offer.name
      one.url = offer.url
      one.category_id = offer.category_id
      one.description = offer.description
      one.price = offer.price
      one.currency_id = 'RUB'
      one.delivery = true
      one.add_cover_picture(offer.photo)

      @price.offers.add(one)
      add_category(one.category_id)
    end

    @price.save(File.join(folders[:app], 'price-list.xml'))
    0
  end

end

app = GenerateYandexPriceList.new(ARGV, __dir__)

app.version = '1.0'
app.releasedate = '2015-05-14'
app.shortdescription = 'Генерация прайс-листа для Yandex.Market'
app.description = "CliApplication gem демо. #{app.shortdescription}"

app.set_argv(:range, 'categories', '', 'Список категорий, включенных в прайс-лист')

app.help

app.run
exit(app.exitcode)
```

Запускаем приложение, и директории, где расположен файл `price.rb` и находим в нем фпйл `price-list.xml` следующего
соджержания (обратите внимание, что оригинальный файл - в кодировке windows-1251).

```xml
<?xml version="1.0" encoding="windows-1251"?>
<!DOCTYPE yml_catalog SYSTEM "shops.dtd">
<yml_catalog date="2015-05-14 19:06">
  <shop>
    <name>Тестовый магазин</name>
    <company>ООО &apos;Рога &amp; Копыта&apos;</company>
    <url>http://test</url>
    <phone>+7 (495) 123-4567</phone>
    <email>info@test.ru</email>
    <currencies>
      <currency id="RUB" rate="1"/>
    </currencies>
    <categories>
      <category id="1">Игрушки</category>
      <category id="2">Одежда</category>
    </categories>
    <local_delivery_cost>300</local_delivery_cost>
    <offers>
      <offer id="1" available="false">
        <url>http://test/pony</url>
        <price>100</price>
        <currencyId>RUB</currencyId>
        <categoryId>1</categoryId>
        <picture>http://test/image1</picture>
        <delivery>true</delivery>
        <name>Пони</name>
        <description>Любимая игрушка для детей</description>
      </offer>
      <offer id="2" available="false">
        <url>http://test/car</url>
        <price>200</price>
        <currencyId>RUB</currencyId>
        <categoryId>1</categoryId>
        <picture>http://test/image2</picture>
        <delivery>true</delivery>
        <name>Машинка</name>
        <description>Любимая игрушка для мальчиков</description>
      </offer>
      <offer id="3" available="false">
        <url>http://test/toy</url>
        <price>230</price>
        <currencyId>RUB</currencyId>
        <categoryId>1</categoryId>
        <picture>http://test/image3</picture>
        <delivery>true</delivery>
        <name>Кукла</name>
        <description>Кукла для девочек</description>
      </offer>
      <offer id="4" available="false">
        <url>http://test/wear</url>
        <price>3100</price>
        <currencyId>RUB</currencyId>
        <categoryId>2</categoryId>
        <picture>http://test/image4</picture>
        <delivery>true</delivery>
        <name>Кофта</name>
        <description>Красивая кофта</description>
      </offer>
      <offer id="5" available="false">
        <url>http://test/boots</url>
        <price>8900</price>
        <currencyId>RUB</currencyId>
        <categoryId>2</categoryId>
        <picture>http://test/image5</picture>
        <delivery>true</delivery>
        <name>Ботинки</name>
        <description>Элегантные ботинки</description>
      </offer>
    </offers>
  </shop>
</yml_catalog>
```

