require "spec_helper"

class MyQueue; end

describe PgQueue::Queue do
  let(:connection) { double("connection").as_null_object }
  let(:result) {  double("result") }
  subject { described_class.new(connection) }

  it "enqueues a job" do
    result.should_receive(:getvalue).with(0, 0).and_return("1")
    connection.should_receive(:exec).and_return(result)
    connection.should_receive(:exec).with(/NOTIFY \w+/)

    subject.enqueue(MyQueue, 1, "two")
  end

  it "returns nil if there no jobs" do
    result.should_receive(:count).and_return(0)
    connection.should_receive(:exec).with(/LIMIT 1/).and_return(result)

    subject.dequeue.should be_nil
  end

  it "dequeues a job" do
    result.should_receive(:count).and_return(1)
    result.should_receive(:[]).with(0).and_return({})
    connection.should_receive(:exec).with(/LIMIT 1/).and_return(result)
    job = double("job", :id => 1)
    PgQueue::Job.should_receive(:new).and_return(job)
    connection.should_receive(:exec).with(/DELETE/, [1])

    subject.dequeue.should == job
  end
end
