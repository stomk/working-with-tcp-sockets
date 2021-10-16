require 'socket'
require_relative "../common"

module FTP
  class Serial
    include Common

    def run
      @client = @control_socket.accept
      respond "220 OHAI"

      handler = CommandHandler.new(self)

      loop do
        if (request = @client.gets(CRLF))
          respond handler.handle(request)
        else
          @client.close
          break
        end
      end
    end

  end
end

server = FTP::Serial.new(4481)
server.run
