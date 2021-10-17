require 'socket'
require_relative "../common"

module FTP
  class Preforking
    include Common

    CONCURRENCY = 4

    def run
      child_pids = []
      CONCURRENCY.times.each do
        child_pids << spawn_child
      end

      trap(:INT) do
        child_pids.each do |cpid|
          Process.kill(:INT, cpid)
        rescue Errno::ESRCH
        end

        exit
      end

      loop do
        pid = Process.wait
        $stedrr.puts "Process #{pid} quit unexpectedly"

        child_pids.delete[pid]
        child_pids << spawn_child
      end
    end

    def spawn_child
      fork do
        loop do
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

  end
end

server = FTP::Preforking.new(4481)
server.run
