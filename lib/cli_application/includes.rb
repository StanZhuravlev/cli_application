# Расширяем стандартные классы, подмешивая туда функционал StTools

class String
  include ::StTools::Module::String
end

class Integer
  include ::StTools::Module::Integer
end

class Time
  include ::StTools::Module::Time
end

class Date
  include ::StTools::Module::Time
end

# class DateTime
#   include ::StTools::Module::Time
# end