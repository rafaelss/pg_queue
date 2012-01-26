require "pg_queue/version"
require "pg"

module PgQueue
  autoload :Worker, "pg_queue/worker"
  autoload :Queue, "pg_queue/queue"
  autoload :Job, "pg_queue/job"
end
