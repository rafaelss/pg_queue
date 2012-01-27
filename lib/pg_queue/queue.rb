require "json"

module PgQueue
  class Queue
    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    def enqueue(klass, *args)
      sql = "INSERT INTO pg_queue_jobs (klass, args) VALUES ($1, $2) RETURNING id"
      id = connection.exec(sql, [klass.name, MultiJson.encode(args)]).getvalue(0, 0)
      puts "enqueued #{id}"
      connection.exec("NOTIFY pg_queue_jobs")
    end

    def dequeue
      result = connection.exec("SELECT id, klass, args FROM pg_queue_jobs LIMIT 1")
      return nil unless result.count == 1
      PgQueue::Job.new(result[0]).tap do |job|
        connection.exec("DELETE FROM pg_queue_jobs WHERE id = $1", [job.id])
      end
    end
  end
end
