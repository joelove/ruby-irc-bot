require 'cinch'
require 'shikashi'

BOOT_TIME = Time.now.to_i

class Numeric
  def duration
    secs  = self.to_int
    mins  = secs / 60
    hours = mins / 60
    days  = hours / 24

    if days > 0
      "#{days} days and #{hours % 24} hours"
    elsif hours > 0
      "#{hours} hours and #{mins % 60} minutes"
    elsif mins > 0
      "#{mins} minutes and #{secs % 60} seconds"
    elsif secs >= 0
      "#{secs} seconds"
    end
  end
end

def parse_message(m, sandbox, privileges)
  msg       = m.message
  msg_size  = msg.size - 1
  ctrl_char = msg[0,1]
  cmd       = msg[-msg_size..-1]

  case ctrl_char
  when "@"
    m.reply match_command(cmd, m)
  when "~"
    result = sandbox.run cmd, privileges
    m.reply '=> ' + result.to_s
  end
end

def match_command(cmd, m)
  case cmd
  when "uptime"
    difference = Time.now.to_i - BOOT_TIME
    "I've been awake for #{difference.duration}, #{m.user.nick}"
  end
end

def init
  sandbox = Shikashi::Sandbox.new
  privileges = Shikashi::Privileges.new
  privileges.allow_method :"+" # mandatory to prevent SecurityError exception

  bot = Cinch::Bot.new do
    configure do |c|
      c.server = "irc.lemondigits.com"
      c.channels = ["#bots", "#shadowacre"]
      c.port = "65534"
      c.nick = "Esme"
    end

    on :message do |m|
      parse_message m, sandbox, privileges
    end
  end
  bot.start
end

init
