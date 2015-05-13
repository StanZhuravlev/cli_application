module CliApplication
  class Argv < OpenStruct

    def initialize(argv)
      @params = Hash.new
      @full = Hash.new

      argv.each do |one|
        if one.match(/[a-z\_0-9]\=/i)
          pair = one.split('=')
          @params[pair.first.to_s.strip.downcase.to_sym] = pair.last
        else
          warn "WARNING: некорректный ключ параметра командной строки: #{one.inspect} (#{File.basename(__FILE__)} at #{__LINE__})"
        end
      end
      super(@params)
    end

    def set_argv(action, key, default, description)
      key = key.downcase.strip.to_sym
      unless @params.keys.include?(key)
        @params[key] = default
      end

      case action
        when :bool, :boolean
          @params[key] = @params[key].to_s.to_bool
        when :split
          @params[key] = ::StTools::String.split(@params[key].to_s, ',', sort: true)
        when :range
          @params[key] = @params[key].to_s.to_range(sort: true, uniq: true)
        when :range_no_uniq
          @params[key] = @params[key].to_s.to_range(sort: true)
        when :float
          @params[key] = @params[key].to_s.strip.to_f
        when :integer
          @params[key] = @params[key].to_s.strip.to_i
        when :downcase
          @params[key] = @params[key].to_s.downcase
        when :upcase
          @params[key] = @params[key].to_s.upcase
        when :normalize
          @params[key] = @params[key].to_s.normalize
        when :caps
          @params[key] = @params[key].to_s.caps
        when :string
          @params[key] = @params[key].to_s
        else
      end

      convert_from_hash
      set_full(action, key, default, @params[key], description)
    end

    def help
      puts
      puts "Параметры приложения:"

      screenwidth = ::StTools::System.screen(:width)
      keylen = self.keylen

      @full.each do |key, data|
        line = get_helpline(key, data[:description], keylen, screenwidth)
        line.each { |x| puts x }
      end
      puts
    end

    protected

    def set_full(action, key, default, value, description)
      @full[key] = Hash.new
      @full[key][:action] = action
      @full[key][:default] = default
      @full[key][:value] = value
      @full[key][:description] = description + ' ' + human_default(action, value, default)
    end

    def human_default(action, value, default)
      type = value.class.to_s
      defval = default.inspect
      "(по умолчанию #{defval}:#{type})"
    end

    def keylen
      keylen = 0
      @full.each do |key, data|
        keylen = key.to_s.length if key.to_s.length > keylen
      end
      keylen
    end

    def get_helpline(key, line, keylen, screenwidth)
      out = Array.new
      width = screenwidth - 2 - keylen - 3
      chunks = line.chars.each_slice(width).map(&:join)

      chunks.each do |one|
        if out.count == 0
          tmp = key.to_s.ljust(keylen, ' ') + ' - '
        else
          tmp = ' '.ljust(keylen, ' ') + '   '
        end
        out << "  #{tmp}#{one.strip}"
        out
      end

      out
    end


    def convert_from_hash
      @params.each do |key, value|
        name = new_ostruct_member(key)
        self[name] = value
      end
    end

    def to_h
      @hash_table
    end

  end
end

