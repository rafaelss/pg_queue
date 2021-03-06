require "pg_queue/version"
require "pg"
require "logger"
require "multi_json"

module PgQueue
  autoload :Worker, "pg_queue/worker"
  autoload :Job, "pg_queue/job"
  autoload :PgExtensions, "pg_queue/pg_extensions"

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.logger=(object)
    @logger = object
  end

  def self.connection
    @connection
  end

  def self.connection=(object)
    @connection = object.tap do |conn|
      conn.extend(PgQueue::PgExtensions) if object.respond_to?(:exec)
    end
  end

  def self.interval
    @interval || 0
  end

  def self.interval=(seconds)
    @interval = seconds
  end

  def self.enqueue(klass, *args)
    id = connection.insert(:pg_queue_jobs, { :class_name => klass.name, :args => MultiJson.encode(args) }, "id")
    logger.debug("enqueued #{id}")
    connection.notify(:pg_queue_jobs)
  end

  def self.dequeue
    result = connection.first("SELECT id, class_name, args FROM pg_queue_jobs LIMIT 1")
    return nil unless result

    PgQueue::Job.new(result).tap do |job|
      PgQueue.logger.debug("dequeued #{job.id}")
      connection.delete(:pg_queue_jobs, :id => job.id)
    end
  end
end
