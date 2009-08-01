require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "A workflow with no states" do
  before do
    klass = Class.new do
      attr_accessor :workflow_state
      include Newflow
    end
    @obj = klass.new
  end

  it "should not validate" do
    lambda { @obj.construct_workflow! }.should raise_error(RuntimeError)
  end
end

describe "A workflow with one state" do
  before do
    klass = Class.new do
      attr_accessor :workflow_state
      include Newflow

      def define_workflow
        state :start
      end
    end
    @obj = klass.new
  end

  it "should not validate" do
    lambda { @obj.construct_workflow! }.should raise_error(RuntimeError)
  end
end

describe "The minimal valid workflow" do
  before do
    klass = Class.new do
      attr_accessor :workflow_state
      include Newflow

      def define_workflow
        state :start, :start => true do
          transitions_to :finish, :if => :go_to_finish?
        end

        state :finish, :stop => true
      end

      def go_to_finish?
        true
      end
    end
    @obj = klass.new
    @obj.construct_workflow!
  end

  it "should validate" do
    lambda { @obj.validate_workflow! }.should_not raise_error(RuntimeError)
  end

  it "should begin in start state" do
    @obj.should be_start
  end

  it "should stop in the finish state" do
    @obj.transition!
    @obj.should be_finish
  end
end

