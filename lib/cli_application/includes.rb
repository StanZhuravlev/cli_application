# Расширяем стандартные классы, подмешивая туда функционал StTools

class String # :nodoc:
  include ::StTools::Module::String
end

class Integer # :nodoc:
  include ::StTools::Module::Integer
end

class Time  # :nodoc:
  include ::StTools::Module::Time
end

class Date  # :nodoc:
  include ::StTools::Module::Time
end

# class DateTime
#   include ::StTools::Module::Time
# end