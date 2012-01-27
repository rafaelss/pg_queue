require "multi_json"

module PgQueue
  class Job
    attr_reader :id, :klass, :args

    def initialize(attributes)
      @id = attributes["id"]
      @klass = Object.const_get(attributes["class_name"])
      @args = MultiJson.decode(attributes["args"])
    end

    def perform
      PgQueue.logger.debug("performing job #{@id}")
      klass.perform(*args)
      PgQueue.logger.debug("job #{@id} performed")
    end
  end
end
