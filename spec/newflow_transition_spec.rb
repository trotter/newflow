require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "An :if symbol transition with a symbol trigger" do
  before do
    @workflow = mock("workflow")
    @transition = Newflow::Transition.new(:target_state, :if => :predicate?, :trigger => :some_action)
  end

  it "should not be able to transition if predicate is false" do
    @workflow.should_receive(:predicate?).and_return false
    @transition.can_transition?(@workflow).should be_false
  end

  it "should be able to transition if predicate is true" do
    @workflow.should_receive(:predicate?).and_return true
    @transition.can_transition?(@workflow).should be_true
  end

  it "should call the trigger if requested" do
    @workflow.should_receive(:some_action)
    @transition.trigger!(@workflow)
  end

  it "should have a predicate name" do
    @transition.predicate_name.should == "predicate?"
  end

  it "should have a target state" do
    @transition.target_state.should == :target_state
  end
end

describe "An :unless symbol transition with a proc trigger" do
  before do
    @workflow = mock("workflow")
    @trigger_ran = false
    @trigger  = lambda { @trigger_ran = true }
    @transition = Newflow::Transition.new(:target_state, :unless => :predicate?, :trigger => @trigger)
  end

  it "should not be able to transition if predicate is true" do
    @workflow.should_receive(:predicate?).and_return true
    @transition.can_transition?(@workflow).should be_false
  end

  it "should be able to transition if predicate is false" do
    @workflow.should_receive(:predicate?).and_return false
    @transition.can_transition?(@workflow).should be_true
  end

  it "should call the trigger when requested" do
    @transition.trigger!(@workflow)
    @trigger_ran.should be_true
  end

  it "should have a predicate name" do
    @transition.predicate_name.should == "!predicate?"
  end
end

describe "An :if proc transition with no trigger" do
  before do
    @workflow = mock("workflow")
    @if_proc  = lambda { @predicate_value }
    @transition = Newflow::Transition.new(:target_state, :if => @if_proc)
  end

  it "should not be able to transition if predicate is false" do
    @predicate_value = false
    @transition.can_transition?(@workflow).should be_false
  end

  it "should be able to transition if predicate is true" do
    @predicate_value = true
    @transition.can_transition?(@workflow).should be_true
  end

  it "should do nothing when triggered" do
    lambda { @transition.trigger!(@workflow) }.should_not raise_error
  end
end

describe "An :unless proc transition with no trigger" do
  before do
    @workflow    = mock("workflow")
    @unless_proc = lambda { @predicate_value }
    @transition  = Newflow::Transition.new(:target_state, :unless => @unless_proc)
  end

  it "should not be able to transition if predicate is true" do
    @predicate_value = true
    @transition.can_transition?(@workflow).should be_false
  end

  it "should be able to transition if predicate is false" do
    @predicate_value = false
    @transition.can_transition?(@workflow).should be_true
  end
end

describe "Invalid triggers" do
  it "should not be valid without an if or unless" do
    lambda { @transition = Newflow::Transition.new(:target_state) }.should raise_error
  end

  it "should not be valid with an if and an unless" do
    lambda { @transition = Newflow::Transition.new(:target_state, :unless => :unless, :if => :if) }.should raise_error
  end
end
