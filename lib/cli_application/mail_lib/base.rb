# CliApplication::MailLib::Base - базовый класс валидации конфига почты

module CliApplication
  module MailLib
    class Base
      attr_reader :delivery_method
      attr_reader :config_fail_message

      def initialize(config, folders)
        @config = config
        @folders = folders
      end

      # Метод возвращает true, если подсистема отсылки почтовых сообщений настроена корректна
      # и готова к рассылке сообщений
      #
      # @return [Boolean] true - если подсистема почта настроена корректно
      def valid?
        @is_valid
      end

      # Метод является заглушкой функции, которая должна быть переписана в дочерних классах
      # ::Log, ::Error, ::Smpt, ::Sendmail
      #
      # @param [String] to электронная почта лица, которому отправляется сообщение
      # @param [String] name имя клиента, которому отправляется сообщение
      # @param [String] title заголовок письма
      # @param [String] body текст письма
      # @return [Boolean] true, если письмо отправлено
      def simple_send(to, name, title, body)
        warn "Необходимо переопределить функцию отправки электронной почты (simple_send)"
        warn "Обратитесь к разработчику данного скрипта"
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Log
      #
      # @return [String] пустая строка
      def log_filename
        ''
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Smtp
      #
      # @return [String] пустая строка
      def address
        ''
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Smtp
      #
      # @return [String] пустая строка
      def domain
        ''
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Smtp
      #
      # @return [String] пустая строка
      def port
        ''
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Smtp
      #
      # @return [String] пустая строка
      def user_name
        ''
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Smtp
      #
      # @return [Boolean] необходимость использовать SSL/TLS
      def tls?
        false
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Smtp
      #
      # @return [Boolean] необходимость использовать SSL/TLS
      def smpt_log?
        false
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Smtp
      #
      # @return [String] пустая строка
      def authentication
        ''
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Smtp
      #
      # @return [String] пустая строка
      def password
        ''
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Sendmail
      #
      # @return [String] пустая строка
      def sendmail_location
        ''
      end

      # Заглушка на случай вызова данной функции из класса иного, чем CliApplication::MailLib::Sendmail
      #
      # @return [String] пустая строка
      def sendmail_arguments
        ''
      end


      private



      def set_check_config_state(state, message)
        @is_valid = state
        @config_fail_message = message
        state
      end

      def build_rfc822_name(to, name)
        return to if name.nil? || name == ''
        "#{name} <#{to}>"
      end

      def processing_to(to, name, message)
        if to.is_a?(::Array)
          # Несколько адресов
          to.each do |one|
            message.add_to(one, '')
          end
        else
          # Один адрес
          message.add_to(to, name)
        end
      end

      # https://github.com/premailer/premailer/blob/master/lib/premailer/html_to_plain_text.rb
      def html_to_text(html, line_length = 65, from_charset = 'UTF-8')
        txt = html

        # strip text ignored html. Useful for removing
        # headers and footers that aren't needed in the
        # text version
        txt.gsub!(/<!-- start text\/html -->.*?<!-- end text\/html -->/m, '')

        # replace images with their alt attributes
        # for img tags with "" for attribute quotes
        # with or without closing tag
        # eg. the following formats:
        # <img alt="" />
        # <img alt="">
        txt.gsub!(/<img.+?alt=\"([^\"]*)\"[^>]*\>/i, '\1')

        # for img tags with '' for attribute quotes
        # with or without closing tag
        # eg. the following formats:
        # <img alt='' />
        # <img alt=''>
        txt.gsub!(/<img.+?alt=\'([^\']*)\'[^>]*\>/i, '\1')

        # links
        txt.gsub!(/<a\s.*?href=\"(mailto:)?([^\"]*)\"[^>]*>((.|\s)*?)<\/a>/i) do |s|
          if $3.empty?
            ''
          else
            $3.strip + ' ( ' + $2.strip + ' )'
          end
        end

        txt.gsub!(/<a\s.*?href='(mailto:)?([^\']*)\'[^>]*>((.|\s)*?)<\/a>/i) do |s|
          if $3.empty?
            ''
          else
            $3.strip + ' ( ' + $2.strip + ' )'
          end
        end

        # handle headings (H1-H6)
        txt.gsub!(/(<\/h[1-6]>)/i, "\n\\1") # move closing tags to new lines
        txt.gsub!(/[\s]*<h([1-6]+)[^>]*>[\s]*(.*)[\s]*<\/h[1-6]+>/i) do |s|
          hlevel = $1.to_i

          htext = $2
          htext.gsub!(/<br[\s]*\/?>/i, "\n") # handle <br>s
          htext.gsub!(/<\/?[^>]*>/i, '') # strip tags

          # determine maximum line length
          hlength = 0
          htext.each_line { |l| llength = l.strip.length; hlength = llength if llength > hlength }
          hlength = line_length if hlength > line_length

          case hlevel
            when 1   # H1, asterisks above and below
              htext = ('*' * hlength) + "\n" + htext + "\n" + ('*' * hlength)
            when 2   # H1, dashes above and below
              htext = ('-' * hlength) + "\n" + htext + "\n" + ('-' * hlength)
            else     # H3-H6, dashes below
              htext = htext + "\n" + ('-' * hlength)
          end

          "\n\n" + htext + "\n\n"
        end

        # wrap spans
        txt.gsub!(/(<\/span>)[\s]+(<span)/mi, '\1 \2')

        # lists -- TODO: should handle ordered lists
        txt.gsub!(/[\s]*(<li[^>]*>)[\s]*/i, '* ')
        # list not followed by a newline
        txt.gsub!(/<\/li>[\s]*(?![\n])/i, "\n")

        # paragraphs and line breaks
        txt.gsub!(/<\/p>/i, "\n\n")
        txt.gsub!(/<br[\/ ]*>/i, "\n")

        # strip remaining tags
        txt.gsub!(/<\/?[^>]*>/, '')

        # decode HTML entities
        he = HTMLEntities.new
        txt = he.decode(txt)

        txt = word_wrap(txt, line_length)

        # remove linefeeds (\r\n and \r -> \n)
        txt.gsub!(/\r\n?/, "\n")

        # strip extra spaces
        txt.gsub!(/\302\240+/, " ") # non-breaking spaces -> spaces
        txt.gsub!(/\n[ \t]+/, "\n") # space at start of lines
        txt.gsub!(/[ \t]+\n/, "\n") # space at end of lines

        # no more than two consecutive newlines
        txt.gsub!(/[\n]{3,}/, "\n\n")

        # no more than two consecutive spaces
        txt.gsub!(/ {2,}/, " ")

        # the word messes up the parens
        txt.gsub!(/\([ \n](http[^)]+)[\n ]\)/) do |s|
          "( " + $1 + " )"
        end

        txt.strip
      end

      # Taken from Rails' word_wrap helper (http://api.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html#method-i-word_wrap)
      def word_wrap(txt, line_length)
        txt.split("\n").collect do |line|
          line.length > line_length ? line.gsub(/(.{1,#{line_length}})(\s+|$)/, "\\1\n").strip : line
        end * "\n"
      end


    end
  end
end