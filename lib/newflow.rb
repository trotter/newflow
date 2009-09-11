require 'logger'
require 'forwardable'

# Require all the files
base_dir = File.dirname(__FILE__) + "/newflow"
Dir["#{base_dir}/*.rb"].each { |f| require f }

# TODO: Allow workflows to identify themselves (for logging and stuffs)
module Newflow
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, Forwardable)
    base.def_delegators :workflow, *(Workflow.public_instance_methods(false))
  end

  module InstanceMethods
    def workflow
      @workflow ||= Workflow.new(self)
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

