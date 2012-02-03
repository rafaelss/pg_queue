require "spec_helper"

describe PgQueue::Job do
  let(:queue_class) { Object.const_set("OrdinaryQueue", Class.new) }

  subject do
    described_class.new(
      "id" => 1,
      "class_name" => queue_class.name,
      "args" => MultiJson.encode([1, "two"])
    )
  end

  after do
    Object.send(:remove_const, queue_class.name.to_sym)
  end

  its(:id) { should == 1 }
  its(:klass) { should == OrdinaryQueue }
  its(:args) { should == [1, "two"] }

  it "performs the job" do
    subject.klass.should_receive(:perform)
    subject.perform
  end
end
