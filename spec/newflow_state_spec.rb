require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "A valid start state" do
  before do
    @name  = :start
    @workflow = mock("workflow")
    @state = Newflow::State.new(@name, :start => true) do
      transitions_to :finish, :if => :go_to_finish?
    end
  end

  it "should have a name" do
    @state.name.should == @name
  end

  it "should be a start" do
    @state.should be_start
  end

  it "should turn itself into a string" do
    @state.to_s.should == @name.to_s
  end

  it "should should not bomb when running on entry" do
    lambda { @state.run_on_entry(@extendee) }.should_not raise_error
  end

  it "should return the transition state when the predicate is true" do
    @workflow.should_receive(:go_to_finish?).and_return true
    @state.run(@workflow).should == [:finish, true]
  end

  it "should return the its own state when the predicate is false" do
    @workflow.should_receive(:go_to_finish?).and_return false
    @state.run(@workflow).should == [:start, false]
  end
end

describe "A state with on_entry" do
  before do
    @name = :start
    @extendee = mock("extendee")
    @state = Newflow::State.new(@name, :on_entry => :make_pizza)
  end

  it "should run on entry when triggers are on (default)" do
    @extendee.should_receive(:make_pizza)
    @state.run_on_entry(@extendee)
  end

  it "should not run on entry when triggers are off" do
    @extendee.should_not_receive(:make_pizza)
    @state.run_on_entry(@extendee, Newflow::WITHOUT_SIDE_EFFECTS) 
  end
end

describe "A valid stop state" do
  before do
    @name  = :stop
    @state = Newflow::State.new(@name, :stop => true)
  end

  it "should be a stop" do
    @state.should be_stop
  end
end

describe "Invalid states" do
  it "should not have both a start and a stop" do
    lambda { @state = Newflow::State.new(:hi, :start => true, :stop => true) }.should raise_error
  end
end
