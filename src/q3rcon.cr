# src/q3rcon.cr
require "./q3rcon/client"

module Q3Rcon
  VERSION = "0.2.1"

  class Error < Exception; end

  class LoginTimeoutError < Error; end

  class BadPasswordError < Error; end

  class MissingPasswordError < Error; end
end
