require "pg_queue/version"
require "pg"
require "logger"

module PgQueue
  autoload :Worker, "pg_queue/worker"
  autoload :Job, "pg_queue/job"

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.logger=(object)
    @logger = object
  end

  def self.connection
    @connection ||= begin
      conn = PGconn.open(:dbname => 'pg_queue_test')
    end
  end

  def self.connection=(object)
    @connection = object
  end

end
