require "spec_helper"

class MyLogger; end
class MyDbConnection; end

describe PgQueue do
  context "logging" do
    its(:logger) { should be_instance_of(Logger) }

    it "defines a new logger" do
      described_class.logger = MyLogger.new
      described_class.logger.should be_instance_of(MyLogger)
    end

    after do
      described_class.logger = nil
    end
  end

  context "database connection" do
    its(:connection) { should be_instance_of(PGconn) }

    it "defines a new connection" do
      described_class.connection = MyDbConnection.new
      described_class.connection.should be_instance_of(MyDbConnection)
    end

    after do
      described_class.connection = nil
    end
  end

    end
  end
end
