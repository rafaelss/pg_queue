require "multi_json"

module PgQueue
  class Job
    attr_reader :id, :klass, :args

    def initialize(attributes)
      @id = attributes["id"]
      puts "new job #{@id}"
      @klass = Object.const_get(attributes["klass"])
      @args = MultiJson.decode(attributes["args"])
    end

    def perform
      puts "performing"
      klass.perform(*args)
      puts "performed"
    end
  end
end
