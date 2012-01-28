namespace :pg_queue do
  task :drop_table do
    PgQueue.connection.exec("DROP TABLE IF EXISTS pg_queue_jobs")
  end

  task :create_table => :drop_table do
    PgQueue.connection.exec("CREATE TABLE pg_queue_jobs (id SERIAL, class_name VARCHAR, args TEXT)")
  end
end
