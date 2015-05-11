require '../../../lib/cli_application.rb'

class CliExample < CliApplication::App

  def initialize(argv, folder, lang = :ru)
    super(argv, folder, __dir__, lang)
  end

  def init_app
    super
    add_config('config.yml', :class)
  end

end
