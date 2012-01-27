require "spec_helper"

describe PgQueue do
  its(:logger) { should be_instance_of(Logger) }

  context "setting a logger" do
    after do
      described_class.logger = Logger.new(STDOUT)
    end

    it "should set a new logger" do
      described_class.logger = nil
      described_class.logger.should be_nil
    end
  end
end
