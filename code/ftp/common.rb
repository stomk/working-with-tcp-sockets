require_relative "./common/command_handler"

module FTP
  module Common
    CRLF = "\r\n"

    def initialize(port)
      @control_socket = TCPServer.new(port)
      trap(:INT) { exit }
    end

    def respond(response)
      @client.write(response)
      @client.write(CRLF)
    end
  end
end
