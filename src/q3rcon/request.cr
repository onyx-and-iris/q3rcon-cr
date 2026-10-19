module Q3Rcon
  class Request
    BUF_SZ         = 1024
    REQUEST_HEADER = "\xFF\xFF\xFF\xFFrcon"

    getter password : String
    @buf : Bytes
    @io : IO::Memory

    def initialize(@password : String)
      @buf = Bytes.new(BUF_SZ)
      @io = IO::Memory.new(@buf, writable: true)
    end

    def encode(cmd : String) : Bytes
      raise "command cannot be empty" if cmd.empty?

      @io.rewind
      @io.write(REQUEST_HEADER.to_slice)
      @io << " " << password << " " << cmd

      @buf[0, @io.pos]
    end
  end
end
