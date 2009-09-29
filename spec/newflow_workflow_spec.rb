require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "A workflow" do
  before do
    @klass = Class.new do
      attr_accessor :workflow_state
    end
    @obj = @klass.new
  end

  describe "A workflow with no states" do
    before do
      @definition = lambda {}
    end

    it "should raise an error on creation" do
      lambda { Newflow::Workflow.new(@obj, @definition) }.should raise_error(Newflow::InvalidStateDefinitionError)
    end
  end

  describe "A workflow with one state" do
    before do
      @definition = lambda {
        state :start
      }
    end

    it "should raise an error on creation" do
      lambda { Newflow::Workflow.new(@obj, @definition) }.should raise_error(Newflow::InvalidStateDefinitionError)
    end
  end

  describe "The minimal valid workflow" do
    before do
      @definition = lambda {
        state :start, :start => true do
          transitions_to :finish, :if => :go_to_finish?
        end

        state :finish, :on_entry => :make_pizza, :stop => true
      }

      @klass.send(:define_method, :go_to_finish?) do
        true
      end
      @klass.send(:define_method, :make_pizza) do
        "yum"
      end
      @workflow = Newflow::Workflow.new(@obj, @definition)
    end

    it "should begin in start state" do
      @workflow.should be_start
      @obj.workflow_state.should == "start"
    end

    it "should trigger the on_entry when going to finish" do
      @obj.should_receive :make_pizza
      @workflow.transition!
    end

    it "should be able to transition to the finish state" do
      state = @workflow.would_transition_to
      state.should == :finish
      @workflow.should be_start
    end

    it "should stop in the finish state" do
      @workflow.transition!
      @workflow.should be_finish
      @obj.workflow_state.should == "finish"
    end
  end

  describe "A workflow with an invalid object" do
    before do
      @definition = lambda {
        state :start, :start => true do
          transitions_to :finish, :if => :go_to_finish?
        end

        state :finish, :stop => true
      }

      @klass.send(:define_method, :go_to_finish?) do
        true
      end
      @obj.workflow_state = "invalid"
    end

    it "should raise an error on instantiation" do
      lambda { Newflow::Workflow.new(@obj, @definition) }.should raise_error(Newflow::InvalidWorkflowStateError)
    end
  end
end


