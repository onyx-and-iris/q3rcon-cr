module Q3Rcon
  class Response
    RESPONSE_HEADER = "\xFF\xFF\xFF\xFFprint\n"

    def is_valid(buf : Bytes) : Bool
      header = RESPONSE_HEADER.to_slice
      return false if buf.size < header.size
      buf[0, header.size] == header
    end

    def decode(buf : Bytes) : String
      String.new(buf[RESPONSE_HEADER.bytesize, buf.size - RESPONSE_HEADER.bytesize])
    end
  end
end
