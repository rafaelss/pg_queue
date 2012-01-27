require "spec_helper"

class MyQueue; end

describe PgQueue::Job do
  subject do
    described_class.new(
      "id" => 1,
      "class_name" => "MyQueue",
      "args" => MultiJson.encode([1, "two"])
    )
  end

  its(:id) { should == 1 }
  its(:klass) { should == MyQueue }
  its(:args) { should == [1, "two"] }

  it "performs the job" do
    subject.klass.should_receive(:perform)
    subject.perform
  end
end
