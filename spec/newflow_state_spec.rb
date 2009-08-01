require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "A valid start state" do
  before do
    @name  = :start
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
end

