require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "An empty trigger" do
  before do
    @extendee = mock("extendee")
    @trigger = Newflow::Trigger.new(nil)
  end

  it "should do nothing when running" do
    lambda { @trigger.run!(@extendee) }.should_not raise_error
  end
end

describe "A symbol trigger" do
  before do
    @extendee = mock("extendee")
    @trigger = Newflow::Trigger.new(:make_pizza)
  end

  it "should run the trigger on the workflow" do
    @extendee.should_receive(:make_pizza)
    @trigger.run!(@extendee)
  end
end

describe "An array trigger" do
  before do
    @extendee = mock("extendee")
    @trigger = Newflow::Trigger.new([:make_pizza, :make_cake])
  end

  it "should run the triggers on the workflow" do
    @extendee.should_receive(:make_pizza)
    @extendee.should_receive(:make_cake)
    @trigger.run!(@extendee)
  end
end

describe "A lambda trigger" do
  before do
    @extendee = mock("extendee")
    @trigger = Newflow::Trigger.new(lambda { @extendee.make_pizza })
  end

  it "should run the triggers on the workflow" do
    @extendee.should_receive(:make_pizza)
    @trigger.run!(@extendee)
  end
end

