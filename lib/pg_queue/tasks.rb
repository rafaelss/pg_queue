namespace :pg_queue do
  def start_worker
    worker = PgQueue::Worker.new

    ["INT", "TERM"].each do |signal|
      trap(signal) do
        worker.stop
      end
    end

    yield if block_given?

    worker.start
  end

  desc "Start worker"
  task :work do |args|
    start_worker
  end

  desc "Drop jobs table"
  task :drop_table do
    PgQueue.connection.exec("DROP TABLE IF EXISTS pg_queue_jobs")
  end

  desc "Create jobs table"
  task :create_table => :drop_table do
    PgQueue.connection.exec("CREATE TABLE pg_queue_jobs (id SERIAL, class_name VARCHAR, args TEXT)")
  end

  namespace :work do
    desc "Start worker and put it in background"
    task :start do
      start_worker do
        Process.daemon(true)

        pid_path = File.join(File.expand_path("."), "tmp/pids/pg_queue.pid")
        File.open(pid_path, "w") do |f|
          f.write(Process.pid)
        end
      end
    end

    desc "Stop worker"
    task :stop do
      pid_path = File.join(File.expand_path("."), "tmp/pids/pg_queue.pid")
      Process.kill("TERM", File.read(pid_path).to_i)
      File.unlink(pid_path)
    end
  end
end
