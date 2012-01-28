module PgQueue
  module PgExtensions
    def insert(table_name, hash, returning = nil)
      fields = hash.keys.join(", ")
      variables = hash.size.times.map { |n| "$#{n+1}" }.join(", ")
      sql = "INSERT INTO #{table_name} (#{fields}) VALUES (#{variables})"
      if returning
        sql << " RETURNING #{returning}"
        exec(sql, hash.values).getvalue(0, 0)
      else
        exec(sql, hash.values)
      end
    end

    def delete(table_name, where)
      i = 0
      conditions = where.map { |k, v| i += 1; "#{k} = $#{i}" }.join(" AND ")
      exec("DELETE FROM #{table_name} WHERE #{conditions}", where.values)
    end

    def first(sql)
      result = exec(sql)
      return nil unless result.count > 0
      result[0]
    end

    def notify(key, message = nil)
      sql = "NOTIFY #{key}"
      sql << ", '#{message}'" if message
      exec(sql)
    end

    def listen(key)
      exec("LISTEN #{key}")
    end

    def unlisten(key)
      exec("UNLISTEN #{key}")
    end

    def new_connection
      PGconn.open(
        :host => host,
        :port => port,
        :user => user,
        :password => pass,
        :dbname => db
      ).tap do |conn|
        conn.extend(PgExtensions)
      end
    end
  end
end
