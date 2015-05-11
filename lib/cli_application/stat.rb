module CliApplication
  class Stat
    attr_reader :stat

    def initialize(folders)
      @stat_filename = File.join([folders[:class], 'stat', ::StTools::System.exename.gsub(/\.rb$/, '.yml')])
      @stat_folder = File.join([folders[:class], 'stat'])
      create_folder

      init_stat
      folders[:stat] = @stat_folder
      @stat[:folders] = folders

      @prev = load_stat
    end

    #-------------------------------------------------------------
    #
    # Функции настройки приложения
    #
    #-------------------------------------------------------------
    def exitcode=(code)
      @stat[:last][:exitcode] = code
    end

    def executed_at=(at)
      @stat[:last][:executed_at] = at
    end

    def last_started_at=(at)
      @stat[:last][:started_at] = at.to_s
      @stat[:last_started_at] = at.to_s
    end

    def version=(val)
      @stat[:version] = val
    end

    def description=(val)
      @stat[:description] = val
    end

    def shortdescription=(val)
      @stat[:shortdescription] = val
    end

    def releasedate=(val)
      @stat[:releasedate] = val
    end






    def last_started_at_human
      res = last_started_at
      if res.nil? || res == ''
        'Ранее не запускалось'
      else
        "Последний запуск: #{res.to_time.human_datetime} (#{res.to_time.human_ago})"
      end
    end

    def startes_human
      res = @prev[:avg][:starts]
      "Всего было #{res} запусков"
    end

    def last_started_at
      @prev[:last][:started_at] || ::Time.zone.now
    end

    def load_stat
      YAML.load_file(@stat_filename)
    rescue
      Marshal.load( Marshal.dump(init_stat))
    end

    def save
      @prev = load_stat
      update_stat
      File.open(@stat_filename, 'w') {|f| f.write @prev.to_yaml }
    end

    def create_folder
      unless Dir.exist?(@stat_folder)
        Dir.mkdir(@stat_folder, 0777)
      end
    end

    def timezone=(val)
      @stat[:timezone] = val
    end

    def update_stat
      @prev[:name] = @stat[:name]
      @prev[:shortdescription] = @stat[:shortdescription]
      @prev[:version] = @stat[:version]
      @prev[:releasedate] = @stat[:releasedate]
      @prev[:timezone] = ::Time.zone.name
      @prev[:last_started_at] = @stat[:last_started_at]
      @prev[:folders] = @stat[:folders]

      make_averages(@prev[:avg])
      make_last(@prev[:last])

      tmp = Array.new
      tmp << @prev[:last_started_at]
      tmp << @prev[:last][:exitcode]
      tmp << @prev[:last][:executed_at]
      tmp << @prev[:last][:memory]

      @prev[:last10].unshift(tmp.join(','))
      @prev[:last10] = @prev[:last10][0,10]
    end

    def init_stat
      @stat = Hash.new
      @stat[:name] = ::StTools::System.exename
      @stat[:shortdescription] = ''
      @stat[:version] = ''
      @stat[:releasedate] = ''
      @stat[:timezone] = ''
      @stat[:last_started_at] = ''
      @stat[:folders] = @folders

      @stat[:avg] = Hash.new
      @stat[:avg][:starts] = 0
      @stat[:avg][:executed_at] = 0
      @stat[:avg][:executed_at_human] = ''
      @stat[:avg][:memory] = 0

      @stat[:last] = Hash.new
      @stat[:last][:started_at] = nil
      @stat[:last][:executed_at] = 0
      @stat[:last][:executed_at_human] = ''
      @stat[:last][:memory] = ''
      @stat[:last][:exitcode] = 0

      @stat[:last10] = Array.new

      @stat
    end

    def make_averages(avg)
      if avg[:starts] == 0
        avg[:starts] = 1
        avg[:executed_at] = @stat[:last][:executed_at]
        avg[:executed_at_human] = ::StTools::Human.ago_in_words_pair(avg[:executed_at].to_i).join(' ')
        avg[:memory] = ::StTools::System.memory.to_i
      else
        mul = avg[:starts]
        avg[:starts] += 1
        avg[:executed_at] = ((avg[:executed_at]*mul + @stat[:last][:executed_at]).to_f / avg[:starts]).round(6)
        avg[:executed_at_human] = ::StTools::Human.ago_in_words_pair(avg[:executed_at]).join(' ')
        avg[:memory] = (avg[:memory]*mul + ::StTools::System.memory).to_i / avg[:starts]
      end
    end

    def make_last(last)
      last[:started_at] = @stat[:last_started_at]
      last[:executed_at] = @stat[:last][:executed_at]
      last[:executed_at_human] = ::StTools::Human.ago_in_words_pair(last[:executed_at]).join(' ')
      last[:memory] = ::StTools::Human.memory
      last[:exitcode] = @stat[:last][:exitcode]
    end

  end
end