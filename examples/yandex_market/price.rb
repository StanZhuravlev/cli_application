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

