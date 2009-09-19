require 'logger'
require 'forwardable'

# Require all the files
base_dir = File.dirname(__FILE__) + "/newflow"
Dir["#{base_dir}/*.rb"].each { |f| require f }

# TODO: Allow workflows to identify themselves (for logging and stuffs)
module Newflow
  class InvalidStateDefinitionError < ArgumentError; end
  class InvalidWorkflowStateError < ArgumentError; 
    def initialize(state)
      @state = state
    end

    def message
      "'#{@state}' is not a valid state"
    end
  end

  WITH_SIDE_EFFECTS    = true
  WITHOUT_SIDE_EFFECTS = false

  def self.included(base)
    base.send(:include, InstanceMethods)
    if base.ancestors.map {|a| a.to_s }.include?("ActiveRecord::Base")
      base.send(:include, ActiveRecordInstantiator)
    else
      base.send(:include, NonActiveRecordInstantiator)
    end
    base.send(:extend, ClassMethods, Forwardable)
    base.def_delegators :workflow, :transition!, :transition_once!, :current_state, :current_state=,
                        :would_transition_to
  end

  module ActiveRecordInstantiator # TODO: TEST
    def after_initialize_with_workflow
      after_initialize_without_workflow if respond_to?(:after_initialize_without_workflow)
      workflow # This will set the workflow_state
    end
    if respond_to?(:after_initialize)
      alias_method :after_initialize_without_workflow, :after_initialize
    end
    alias_method :after_initialize, :after_initialize_with_workflow
  end

  module NonActiveRecordInstantiator
    def initialize_with_workflow(*args, &block)
      initialize_without_workflow(*args, &block)
      workflow # This will set the workflow_state
    end
    alias_method :initialize_without_workflow, :initialize
    alias_method :initialize, :initialize_with_workflow
  end

  module InstanceMethods
    def workflow
      @workflow ||= Workflow.new(self, self.class.__workflow_definition)
    end
  end

  module ClassMethods
    def define_workflow(&workflow_definition)
      @__workflow_definition = workflow_definition
      __define_query_methods(workflow_definition)
    end

    def __define_query_methods(workflow_definition)
      @state_catcher = Object.new
      @state_catcher.instance_variable_set("@states", [])
      def @state_catcher.states; @states; end
      def @state_catcher.state(name, *args); @states << name; end
      @state_catcher.instance_eval &workflow_definition
      @state_catcher.states.each do |state|
        self.send(:define_method, "#{state}?") do 
          workflow.send("#{state}?")
        end
      end
    end

    def __workflow_definition
      @__workflow_definition
    end
  end

  def self.logger
    return @logger if @logger
    @logger = if defined?(Rails)
                Rails.logger
              else
                Logger.new(File.open('/dev/null', 'w'))
              end
  end
end

