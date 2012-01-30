module PgQueue
  class Worker
    def start
      @running = true

      PgQueue.connection.listen(:pg_queue_jobs)
      while running?
        job = PgQueue.dequeue
        if job
          perform(job)
          sleep(PgQueue.interval) if PgQueue.interval > 0
          next
        end

        PgQueue.logger.debug("waiting for jobs")
        PgQueue.connection.wait_for_notify do |event, pid, payload|
          if payload == "stop"
            PgQueue.logger.debug("stop notify received")
            stop
          else
            PgQueue.logger.debug("let's perform some jobs")
          end
        end
      end
      PgQueue.connection.unlisten(:pg_queue_jobs)
    end

    def stop
      @running = false
      PgQueue.connection.new_connection.notify(:pg_queue_jobs, "stop")
    end

    def running?
      @running
    end

    protected

    def perform(job)
      begin
        PgQueue.logger.debug(job.inspect)
        job.perform
      rescue => ex
        PgQueue.logger.fatal(ex)
        PgQueue.logger.fatal(ex.message)
        PgQueue.logger.fatal(ex.backtrace)
      end
    end
  end
end
