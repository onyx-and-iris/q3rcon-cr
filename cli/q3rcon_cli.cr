#!/usr/bin/env crystal

require "../src/q3rcon"
require "option_parser"

def strip_colors(s : String) : String
  s.gsub(/\^\d/, "")
end

# --- ENV DEFAULTS ---
host = ENV["Q3RCON_HOST"]? || "127.0.0.1"
port = (ENV["Q3RCON_PORT"]? || "28960").to_i
password = ENV["Q3RCON_PASSWORD"]? || ""
interactive = false
command = ""

# --- FLAGS OVERRIDE ENV ---
OptionParser.parse do |parser|
  parser.banner = "Usage: q3rcon [options] <command>"

  parser.on("-h HOST", "--host HOST", "Server host") { |v| host = v }
  parser.on("-p PORT", "--port PORT", "Server port") { |v| port = v.to_i }
  parser.on("-w PASS", "--password PASS", "RCON password") { |v| password = v }
  parser.on("-i", "--interactive", "Interactive mode") { interactive = true }

  parser.on("--version", "Show version") do
    puts "q3rcon #{Q3Rcon::VERSION}"
    exit
  end

  parser.on("--help", "Show help") do
    puts parser
    exit
  end

  parser.unknown_args do |args|
    command = args.join(" ").strip
  end
end

if password.empty?
  STDERR.puts "Error: password is required"
  exit 1
end

timeouts = {
  "map"         => 1.second,
  "map_rotate"  => 1.second,
  "map_restart" => 1.second,
}

begin
  client = Q3Rcon::Client.new(host, port, password, timeouts: timeouts)
rescue ex : Q3Rcon::LoginTimeoutError | Q3Rcon::BadPasswordError | Q3Rcon::MissingPasswordError
  STDERR.puts "Error: #{ex.class} #{ex.message}"
  exit 1
end

# --- INTERACTIVE MODE ---
if interactive
  puts "Interactive RCON mode. Enter commands, or 'Q' to quit."

  loop do
    print "> "
    raw = gets
    break unless raw

    input = raw.strip
    break if input.upcase == "Q"
    next if input.empty?

    begin
      resp = client.exec(input)
      puts strip_colors(resp)
    rescue ex
      STDERR.puts "Error: #{ex.class} #{ex.message}"
    end
  end

  exit 0
end

# --- SINGLE COMMAND MODE ---
if command.empty?
  STDERR.puts "Error: command is required"
  exit 1
end

resp = client.exec(command)
puts strip_colors(resp)
