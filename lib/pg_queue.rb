require "pg_queue/version"
require "pg"
require "logger"

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
    @connection ||= begin
      conn = PGconn.open(:dbname => 'pg_queue_test')
      conn.extend(PgQueue::PgExtensions)
    end
  end

  def self.connection=(object)
    @connection = object
  end

end
