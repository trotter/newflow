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

  it "should return the transition state when the predicate is true" do
    @workflow.should_receive(:go_to_finish?).and_return true
    @state.run(@workflow).should == :finish
  end

  it "should return the its own state when the predicate is false" do
    @workflow.should_receive(:go_to_finish?).and_return false
    @state.run(@workflow).should == :start
  end
end

