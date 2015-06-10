$LOAD_PATH.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require "cli_application/version"
require 'st_tools'
require 'cli_application/includes'

require 'rubygems'
require 'active_support/time'
require 'mysql2'
require 'pg'
require 'sqlite3'
require 'active_record'
require 'ostruct'
require 'net/smtp'
require 'htmlentities'
require "base64"


module CliApplication  # :nodoc:
  require 'cli_application/mail_lib/message'
  require 'cli_application/mail_lib/base'
  require 'cli_application/mail_lib/error'
  require 'cli_application/mail_lib/smtp'
  require 'cli_application/mail_lib/sendmail'
  require 'cli_application/mail_lib/log'

  require 'cli_application/json_struct'
  require 'cli_application/config'
  require 'cli_application/databases'
  require 'cli_application/mail'
  require 'cli_application/stat'
  require 'cli_application/argv'
  require 'cli_application/app'
end
