# CliApplication::MailLib::Message - сборка сообщения электронной почты

module CliApplication
  module MailLib
    class Message
      attr_reader :from_email
      attr_accessor :from_name
      attr_reader :reply_to
      attr_accessor :subject
      attr_accessor :charset
      attr_accessor :body

      #  Конструктор инициализирует сообщение электронной почты и компоненты сообщения
      #
      # @return [None] нет
      def initialize
        @charset = 'utf-8'
        @body = ''
        @subject = ''
        @from_email = ''
        @from_name = ''
        @reply_to = ''

        @to = Hash.new
        @cc = Hash.new
        @bcc = Hash.new

        @message_id = ::Time.now.to_s.hash.abs.to_s + '.' + ::Time.now.usec.to_s
      end

      # Метод осуществляет сборку (композицию) сообщения в формате MIME для записи в лог файл
      # без преобразований base64
      #
      # @return [String] сообщение электронной почты в виде форматированного текста
      def to_log
        message = Array.new
        message << "From: #{build_rfc822_name(@from_email, @from_name, false)}" unless @from_email == ''
        message << build_to_adresses("To", @to, false)
        message << build_to_adresses("Cc", @cc, false)
        message << build_to_adresses("Bcc", @bcc, false)
        message << "Reply-To: #{build_rfc822_name(@reply_to)}" unless @reply_to == ''
        message << "Subject: #{@subject}"
        message << html_to_text(@body.dup, 65, @charset)

        message.compact!
        message.join("\n")
      end

      # Метод осуществляет сборку (композицию) сообщения в формате MIME для отправки в Интернет.
      # Поля TO, CC, BCC, Subject преобразуются в бинарную форму через base64
      #
      # @return [String] сообщение электронной почты в виде форматированного текста
      def to_s
        message = Array.new
        message << "From: #{build_rfc822_name(@from_email, @from_name)}" unless @from_email == ''
        message << "Return-Path: <#{@from_email}>" # http://maksd.info/blog/vse-posty-iz-starogo-bloga/message-75/
        message << build_to_adresses("To", @to)
        message << build_to_adresses("Cc", @cc)
        message << build_to_adresses("Bcc", @bcc)
        message << "Reply-To: #{build_rfc822_name(@reply_to)}" unless @reply_to == ''
        message << "Subject: #{base64_string_encode(@subject)}"
        message << "Date: #{::Time.zone.now.to_formatted_s(:rfc822) }"
        message << "MIME-Version: 1.0 (Ruby gem cli_application; version #{::CliApplication::VERSION})"
        message << "Message-ID: <#{@message_id + '@' + @from_email.split('@').last}>"
        message += alternative_to_s
        message += body_to_s(html_to_text(@body.dup, 65, @charset), 'text/plain')
        message += body_to_s(@body, 'text/html')
        message += footer_to_s

        message.compact!
        message.join("\n")
      end

      # Метод добавляет к сообщению указание на адрес и имя отправителя. Принимается формат вида
      # "Name <name@host.ru>". При этом будет осуществлен корректный разбор строки на имя и адрес
      #
      # @param [String] val строка с адресом электронной почты
      # @return [None] нет
      # @example Примеры использования
      #   msg = CliApplication::MailLib::Message.new
      #   msg.from_email = "Name <user@host.ru>"
      #   msg.from_email                            #=> "user@host.ru"
      #   msg.from_name                             #=> "Name"
      #
      #   msg.from_email = "user@host.ru"
      #   msg.from_email                            #=> "user@host.ru"
      #   msg.from_name                             #=> ""
      def from_email=(val)
        res = parse_email(val)
        @from_name = res[:name]
        @from_email = res[:email]
      end

      # Метод добавляет к сообщению указание на адрес для ответа. Принимается формат вида
      # "Name <name@host.ru>". При этом будет осуществлен корректный разбор строки на имя и адрес
      #
      # @param [String] val строка с адресом электронной почты
      # @return [None] нет
      # @example Примеры использования
      #   msg = CliApplication::MailLib::Message.new
      #   msg.reply_to = "Name <user@host.ru>"
      #   msg.reply_to                                  #=> "user@host.ru"
      def reply_to=(val)
        res = parse_email(val)
        @reply_to = res[:email]
      end

      # Метод добавляет в поле TO получателя сообщения. Может вызываться несколько раз для
      # добавления нескольких получателей. Особенности обработки. Если в метод передать значения адреса, включающего
      # имя пользователя, то параметр name будет проигнорирован. Name будет взят из переданного адреса.
      #
      # @param [String] email адрес получателя в формате "user@host.ru" или "Name <user@host.ru>"
      # @param [String] name имя пользователя
      # @return [None] нет
      # @example Примеры использования
      #   msg = CliApplication::MailLib::Message.new
      #   msg.add_to('user@host.ru', 'Name')              #=> добавлено: "Name" и "user@host.ru"
      #   msg.add_to('USerName <user@host.ru>', 'Name')   #=> добавлено: "UserName" и "user@host.ru"
      def add_to(email, name = '')
        res = parse_email(email)
        if name == ''
          @to[res[:email]] = res[:name]
        else
          @to[res[:email]] = name
        end
      end

      # Метод добавляет в поле CC получателя сообщения. Может вызываться несколько раз для
      # добавления нескольких получателей. Особенности обработки. Если в метод передать значения адреса, включающего
      # имя пользователя, то параметр name будет проигнорирован. Name будет взят из переданного адреса. Вторая
      # особенность - при использовании метода отправки :smtp, все CC-адреса будут помещены в TO.
      #
      # @param [String] email адрес получателя в формате "user@host.ru" или "Name <user@host.ru>"
      # @param [String] name имя пользователя
      # @return [None] нет
      # @example Примеры использования
      #   msg = CliApplication::MailLib::Message.new
      #   msg.add_cc('user@host.ru', 'Name')              #=> добавлено: "Name" и "user@host.ru"
      #   msg.add_cc('USerName <user@host.ru>', 'Name')   #=> добавлено: "UserName" и "user@host.ru"
      def add_cc(email, name = '')
        res = parse_email(email)
        if name == ''
          @cc[res[:email]] = res[:name]
        else
          @cc[res[:email]] = name
        end
      end

      # Метод добавляет в поле BCC получателя сообщения. Может вызываться несколько раз для
      # добавления нескольких получателей. Особенности обработки. Если в метод передать значения адреса, включающего
      # имя пользователя, то параметр name будет проигнорирован. Name будет взят из переданного адреса. Вторая
      # особенность - при использовании метода отправки :smtp, все BCC-адреса будут удалены.
      #
      # @param [String] email адрес получателя в формате "user@host.ru" или "Name <user@host.ru>"
      # @param [String] name имя пользователя
      # @return [None] нет
      # @example Примеры использования
      #   msg = CliApplication::MailLib::Message.new
      #   msg.add_bcc('user@host.ru', 'Name')              #=> добавлено: "Name" и "user@host.ru"
      #   msg.add_bcc('USerName <user@host.ru>', 'Name')   #=> добавлено: "UserName" и "user@host.ru"
      def add_bcc(email, name = '')
        res = parse_email(email)
        if name == ''
          @bcc[res[:email]] = res[:name]
        else
          @bcc[res[:email]] = name
        end
      end

      # Метод очищает все ранее добавленные адреса TO.
      #
      # @param [Boolean] warning true для вывода предупреждения об удалении всех адресатов
      # @return [None] нет
      def clear_to(warning = false)
        unless @to.empty?
          if warning
            warn "Предупреждение: TO-адреса #{@to.inspect} удалены"
          end
          @to = Hash.new
        end
      end

      # Метод очищает все ранее добавленные адреса CC.
      #
      # @param [Boolean] warning true для вывода предупреждения об удалении всех адресатов
      # @return [None] нет
      def clear_cc(warning = false)
        unless @cc.empty?
          if warning
            warn "Предупреждение: CC-адреса #{@cc.inspect} удалены"
          end
          @cc = Hash.new
        end
      end

      # Метод очищает все ранее добавленные адреса BCC.
      #
      # @param [Boolean] warning true для вывода предупреждения об удалении всех адресатов
      # @return [None] нет
      def clear_bcc(warning = false)
        unless @bcc.empty?
          if warning
            warn "Предупреждение: BCC-адреса #{@bcc.inspect} удалены"
          end
          @bcc = Hash.new
        end
      end



      private



      def to_emails # :nodoc:
        out = build_to_adresses('', @to).gsub(/\A\:/, '')
        out += ',' + build_to_adresses('', @cc).gsub(/\A\:/, '') unless @cc.empty?
        StTools::String.split(out, ',')
      end

      def base64_string_encode(str) # :nodoc:
        "=?UTF-8?B?" + Base64.strict_encode64(str) + "?="
      end

      def build_to_adresses(prefix, to, base64 = true) # :nodoc:
        return nil if to.empty?

        out = Array.new
        to.each do |email, name|
          out << build_rfc822_name(email, name, base64)
        end

        "#{prefix}: #{out.join(", ")}"
      end

      def build_rfc822_name(email, name, base64 = true) # :nodoc:
        return "#{email}" if name.nil? || name == ''
        if base64
          "#{base64_string_encode(name)} <#{email}>"
        else
          "#{name.inspect} <#{email}>"
        end
      end

      def parse_email(str) # :nodoc:
        name = str.strip.match(/^.+\</)[0] rescue nil
        if name.nil?
          {name: '', email: str.strip}
        else
          {name: name.chomp('<').strip, email: str.strip.gsub(name, '').chomp('>')}
        end
      end

      # https://github.com/premailer/premailer/blob/master/lib/premailer/html_to_plain_text.rb
      def html_to_text(html, line_length = 65, from_charset = 'UTF-8') # :nodoc:
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
      def word_wrap(txt, line_length) # :nodoc:
        txt.split("\n").collect do |line|
          line.length > line_length ? line.gsub(/(.{1,#{line_length}})(\s+|$)/, "\\1\n").strip : line
        end * "\n"
      end

      def boundary # :nodoc:
        'NextPart_' + @message_id.gsub(/\./, '_')
      end

      def alternative_to_s # :nodoc:
        message = Array.new
        message << "Content-Type: multipart/alternative; boundary=\"#{boundary}\""
        message
      end

      def body_to_s(text, type) # :nodoc:
        message = Array.new
        message << ""
        message << "--#{boundary}"
        message << "Content-Transfer-Encoding: 8bit"
        message << "Content-Type: #{type}; charset=\"#{@charset}\""
        message << ""
        message << text
        message
      end

      def footer_to_s # :nodoc:
        message = Array.new
        message << ""
        message << "--#{boundary}--"
        message << ""
        message
      end

    end
  end
end
