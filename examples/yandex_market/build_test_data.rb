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

