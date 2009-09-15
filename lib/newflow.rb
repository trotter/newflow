require 'logger'
require 'forwardable'

# Require all the files
base_dir = File.dirname(__FILE__) + "/newflow"
Dir["#{base_dir}/*.rb"].each { |f| require f }

# TODO: Allow workflows to identify themselves (for logging and stuffs)
module Newflow
  class InvalidStateDefinitionError < ArgumentError; end

  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods, Forwardable)
    base.def_delegators :workflow, :transition!, :transition_once!, :current_state, :current_state=
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

