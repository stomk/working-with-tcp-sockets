require 'socket'
require 'thread'
require_relative "../common"

module FTP
  class ThreadPerConnection
    include Common

    def run
      Thread.abort_on_exception = true

      loop do
        @client = @control_socket.accept

        Thread.new do
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

  end
end

server = FTP::ThreadPerConnection.new(4481)
server.run
