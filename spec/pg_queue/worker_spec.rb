require "spec_helper"

describe PgQueue::Worker do
  subject { described_class.new }
  before do
    PgQueue.connection = double("connection").as_null_object
  end

  context "starting" do
    before do
      PgQueue.connection.should_receive(:listen).with(:pg_queue_jobs)
      [true, false].each { |ret| subject.should_receive(:running?).and_return(ret) }
      PgQueue.connection.should_receive(:unlisten).with(:pg_queue_jobs)
    end

    context "with jobs pending" do
      let(:job) { double("job") }

      it "performs the job" do
        PgQueue.should_receive(:dequeue).and_return(job)
        job.should_receive(:perform)

        subject.start
      end
    end

    context "with no jobs pending" do
      it "waits for notifies" do
        PgQueue.should_receive(:dequeue).and_return(nil)
        PgQueue.connection.should_receive(:wait_for_notify).and_yield("pg_queue_jobs", "12345", nil)

        subject.start
      end
    end

    context "with interval" do
      let(:job) { double("job") }

      before do
        PgQueue.should_receive(:dequeue).and_return(job)
        job.should_receive(:perform)
      end

      after do
        PgQueue.interval = nil
      end

      it "should not sleep if an interval is not defined" do
        subject.should_receive(:sleep).never

        subject.start
      end

      it "sleeps if an interval is defined" do
        PgQueue.interval = 5
        subject.should_receive(:sleep).with(5)

        subject.start
      end
    end
  end

  context "stoping" do
    let(:connection) { double("connection") }

    before do
      subject.instance_variable_set(:@running, true)
    end

    it "notifies worker to stop" do
      PgQueue.connection.should_receive(:new_connection).and_return(connection)
      connection.should_receive(:notify).with(:pg_queue_jobs, "stop")

      subject.should be_running
      subject.stop
      subject.should_not be_running
    end
  end
end
