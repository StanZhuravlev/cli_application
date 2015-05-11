#encoding: utf-8

require 'ruby-progressbar'
require '../lib/cli_application.rb'

class CliExample < CliApplication::App

  def initialize(argv, folder, lang = :ru)
    super(argv, folder, __dir__, lang)
  end

  def init_app
    super
    add_config('class_config.yml', :class)
  end

  # Данный метод позволяет загружать модели ActiveRecords
  def init_active_records
    require './tovar.rb'
  end

end

# todo: redmine wiki: создание заголовков категорий и наборов и искоренение type в mysql

