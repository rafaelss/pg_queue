namespace :pg_queue do
  desc "Drop jobs table"
  task :drop_table do
    PgQueue.connection.exec("DROP TABLE IF EXISTS pg_queue_jobs")
  end

  desc "Create jobs table"
  task :create_table => :drop_table do
    PgQueue.connection.exec("CREATE TABLE pg_queue_jobs (id SERIAL, class_name VARCHAR, args TEXT)")
  end
end
