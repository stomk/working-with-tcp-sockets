require 'socket'
require_relative "../common"

module FTP
  class ProcessPerConnection
    include Common

    def run
      @client = @control_socket.accept

      pid = fork do
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

      Process.detach(pid)
    end

  end
end

server = FTP::ProcessPerConnection.new(4481)
server.run
