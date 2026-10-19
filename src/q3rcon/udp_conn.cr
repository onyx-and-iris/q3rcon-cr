require "socket"

module Q3Rcon
  class UDPConn
    getter socket : UDPSocket

    def initialize(host : String, port : Int32)
      @socket = UDPSocket.new
      @socket.connect(host, port)
    end

    def write(data : Bytes) : Int32
      @socket.send(data)
    end

    def read(buf : Bytes, timeout : Time::Span) : Int32
      @socket.read_timeout = timeout
      len, _addr = @socket.receive(buf)
      len
    end

    def close
      @socket.close
    end

    def remote_addr : Socket::Address
      @socket.remote_address
    end
  end
end
