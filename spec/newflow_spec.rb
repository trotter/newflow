require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "An object including Newflow" do
  before do
    klass = Class.new do
      attr_accessor :workflow_state
      include Newflow

      define_workflow do
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
  end

  it "should begin in start state" do
    @obj.should be_start
  end

  it "should stop in the finish state" do
    @obj.transition!
    @obj.should be_finish
  end

  it "should transition once" do
    @obj.transition_once!
    @obj.should be_finish
  end

  it "should have a current state" do
    @obj.current_state.should == :start
  end

  it "should have a workflow state" do
    @obj.workflow_state.should == "start"
  end

  it "should have a way to manually change the current state" do
    @obj.current_state = :finish
    @obj.workflow_state.should == "finish"
    @obj.should be_finish
  end

  it "should not eat all missing methods" do
    lambda { @obj.wammo! }.should raise_error(NoMethodError)
  end

  it "should keep the state even when the workflow is reset" do
    @obj.workflow_state = "finish"
    @obj.instance_variable_set("@workflow", nil)
    @obj.should be_finish
  end
end

