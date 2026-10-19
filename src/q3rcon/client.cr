# src/q3rcon/client.cr
require "./request"
require "./response"
require "./udp_conn"
require "./logging"

module Q3Rcon
  class Client
    RESP_BUF_SZ = 2048

    getter conn : Q3Rcon::UDPConn
    getter request : Request
    getter response : Response

    getter login_timeout : Time::Span
    getter default_timeout : Time::Span
    getter timeouts : Hash(String, Time::Span)

    property logger : Q3Rcon::Logger = Q3Rcon::NullLogger.new

    def initialize(
      host : String,
      port : Int32,
      password : String,
      login_timeout : Time::Span = 5.seconds,
      default_timeout : Time::Span = 20.milliseconds,
      timeouts : Hash(String, Time::Span) = Hash(String, Time::Span).new,
    )
      raise "no password provided" if password.empty?

      @conn = Q3Rcon::UDPConn.new(host, port)
      @request = Request.new(password)
      @response = Response.new
      @login_timeout = login_timeout
      @default_timeout = default_timeout
      @timeouts = timeouts

      login
    end

    def exec(cmd_with_args : String, timeout : Time::Span? = nil) : String
      cmd = cmd_with_args.split.first?
      t = timeout || default_timeout
      if cmd && (custom = timeouts[cmd]?)
        t = custom
      end

      resp_chan = Channel(String).new(1)
      err_chan = Channel(Exception).new(1)

      spawn listen(t, resp_chan, err_chan)

      encoded = request.encode(cmd_with_args)
      conn.write(encoded)

      select
      when err = err_chan.receive
        raise err
      when resp = resp_chan.receive
        resp
      end
    end

    def exec_background(cmd : String) : String
      exec(cmd)
    end

    def close
      conn.close
    end

    private def login
      deadline = Time.utc + login_timeout

      loop do
        raise "login timeout" if Time.utc >= deadline

        resp = exec("login", default_timeout)
        next if resp.empty?

        if resp.includes?("Bad rcon")
          raise "bad rcon password"
        end

        break
      end
    end

    private def listen(timeout : Time::Span, resp_chan : Channel(String), err_chan : Channel(Exception))
      resp_buf = Bytes.new(RESP_BUF_SZ)
      sb = String::Builder.new

      begin
        loop do
          conn.socket.read_timeout = timeout

          begin
            rlen, _addr = conn.socket.receive(resp_buf)
          rescue ex : IO::TimeoutError
            # timeout ends the response collection, like Go/Python
            break
          rescue ex
            err_chan.send(ex)
            return
          end

          slice = resp_buf[0, rlen]
          if response.is_valid(slice)
            sb << response.decode(slice)
          end
        end
      rescue ex
        err_chan.send(ex)
        return
      end

      resp_chan.send(sb.to_s)
    end
  end
end
