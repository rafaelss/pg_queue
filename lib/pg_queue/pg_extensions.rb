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
      conditions = where.map { |k, v| i += 1; "#{k} = $#{i}" }
      exec("DELETE FROM #{table_name} WHERE id = $1", [job.id])
    end

    def first(sql)
      result = exec(sql)
      return nil unless result.count > 0
      result[0]
    end

    def notify(key)
      exec("NOTIFY #{key}")
    end

    def listen(key)
      exec("LISTEN #{key}")
    end
  end
end
