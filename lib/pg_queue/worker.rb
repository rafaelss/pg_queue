module PgQueue
  class Worker
    attr_reader :connection

    def initialize
      @connection = new_connection
      @queue = PgQueue::Queue.new(@connection)
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

        PgQueue.logger.debug("waiting for jobs")
        connection.wait_for_notify do |event, pid, payload|
          if payload == "stop"
            PgQueue.logger.debug("stop notify received")
            stop
          else
            PgQueue.logger.debug("let's perform some jobs")
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
        PgQueue.logger.debug(job.inspect)
        job.perform
      rescue => ex
        PgQueue.logger.fatal(ex)
        PgQueue.logger.fatal(ex.message)
      end
    end
  end
end
