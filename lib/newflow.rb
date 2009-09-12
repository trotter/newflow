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
    base.def_delegators :workflow, :transition!, :transition_once!, :current_state
  end

  module InstanceMethods
    def workflow
      @workflow ||= Workflow.new(self, self.class.__workflow_definition)
    end

    def method_missing_with_state_query(meth, *args, &block)
      if meth.to_s =~ /\?$/ && workflow.respond_to?(meth)
        workflow.send(meth)
      else
        method_missing_without_state_query(meth, *args, &block)
      end
    end
    alias_method :method_missing_without_state_query, :method_missing
    alias_method :method_missing, :method_missing_with_state_query
  end

  module ClassMethods
    def define_workflow(&workflow_definition)
      @__workflow_definition = workflow_definition
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

