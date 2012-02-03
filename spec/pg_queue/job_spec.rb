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

  context "with no hooks" do
    let(:queue_class) { Object.const_set("QueueWithNoAfterPerformHook", Class.new) }

    it "should not try to call after perform hook" do
      subject.klass.should_receive(:perform)
      subject.klass.should_receive(:respond_to?).with(:after_perform).and_return(false)
      subject.klass.should_receive(:after_perform).never
      subject.perform
    end
  end

  context "with hooks" do
    let(:queue_class) { Object.const_set("QueueWithAfterPerformHook", Class.new) }

    it "executes the after perform hook" do
      subject.klass.should_receive(:perform)
      subject.klass.should_receive(:respond_to?).with(:after_perform).and_return(true)
      subject.klass.should_receive(:after_perform).once
      subject.perform
    end
  end
end
