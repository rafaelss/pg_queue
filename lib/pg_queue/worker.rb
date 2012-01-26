module PgQueue
  class Worker
    attr_reader :connection, :interval

    def initialize
      @connection = new_connection
      @queue = PgQueue::Queue.new(@connection)
      @interval = 5
    end

    def start
      @running = true

      listen
      while running?
        job = @queue.dequeue
        if job
          perform(job)
          next
        end

        puts "waiting for jobs"
        connection.wait_for_notify do |event, pid, payload|
          if payload == "stop"
            puts "stop notify received"
            stop
          else
            puts "let's perform some jobs"
          end
        end
      end
    end

    def listen
      connection.exec("LISTEN pg_queue_jobs")
    end

    def unlisten
      connection.exec("UNLISTEN pg_queue_jobs")
    end

    def stop
      @running = false
      new_connection.exec("NOTIFY pg_queue_jobs, 'stop'")
    end

    def running?
      @running
    end

    protected

    def new_connection
      PGconn.open(:dbname => 'pg_queue_test')
    end

    def perform(job)
      begin
        puts job.inspect
        job.perform
      rescue => ex
        puts ex
        puts ex.message
      end
    end
  end
end
