module Q3Rcon
  module Logger
    abstract def debug(msg : String)
    abstract def info(msg : String)
    abstract def warn(msg : String)
    abstract def error(msg : String)
  end

  class NullLogger
    include Logger

    def debug(msg); end

    def info(msg); end

    def warn(msg); end

    def error(msg); end
  end
end
