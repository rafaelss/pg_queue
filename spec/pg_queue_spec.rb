require "spec_helper"

class MyLogger; end
class MyDbConnection; def exec; end; end
class MyQueue; end

describe PgQueue do
  before do
    described_class.connection = MyDbConnection.new
    described_class.logger = Logger.new("/dev/null")
  end

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
    its(:connection) { should be_instance_of(MyDbConnection) }

    context "extensions" do
      subject { described_class.connection }

      it { should respond_to(:insert) }
      it { should respond_to(:notify) }
      it { should respond_to(:delete) }
      it { should respond_to(:first) }
      it { should respond_to(:listen) }
      it { should respond_to(:unlisten) }
      it { should respond_to(:new_connection) }
    end
  end

  context "enqueuing/dequeuing" do
    let(:connection) { described_class.connection }
    let(:result) { double("result") }

    it "enqueues a job" do
      connection.should_receive(:insert).with(:pg_queue_jobs, instance_of(Hash), "id").and_return("1")
      connection.should_receive(:notify).with(:pg_queue_jobs)

      described_class.enqueue(MyQueue, 1, "two")
    end

    it "dequeues a job" do
      connection.should_receive(:first).with(/LIMIT 1/).and_return(result)
      result.should_receive(:[]).with("id").and_return("1")
      result.should_receive(:[]).with("class_name").and_return("MyQueue")
      result.should_receive(:[]).with("args").and_return("[1, \"two\"]")
      connection.should_receive(:delete).with(:pg_queue_jobs, :id => "1")

      subject.dequeue.should be_instance_of(PgQueue::Job)
    end
  end
end
