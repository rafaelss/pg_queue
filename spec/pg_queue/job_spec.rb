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
  its(:class_name) { should == MyQueue }
  its(:args) { should == [1, "two"] }
end
