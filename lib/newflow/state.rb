module Newflow
  class State
    attr_reader :name, :transitions

    def initialize(name, opts={}, &transitions_block)
      logger.debug "State.initialize: name=#{name} opts=#{opts.inspect}"
      @name     = name
      @opts     = opts
      @is_start = opts[:start]
      @is_stop  = opts[:stop]
      @transitions = []
      check_validity
      instance_eval &transitions_block if transitions_block
    end

    def transitions_to(target_state, opts={})
      @transitions << Transition.new(target_state,opts)
    end

    def run(workflow)
      return @name unless @transitions
      # We may want to consider looking at all transitions and letting user know
      # that you can move in multiple directions
      transition_to = @transitions.detect { |t| t.can_transition?(workflow) }
      if transition_to
        transition_to.trigger!(workflow)
        transition_to.target_state
      else
        @name
      end
    end

    # TODO: use convention of name == :start instead of a :start opt, not same for stop
    def start?
      @opts[:start]
    end

    def stop?
      @opts[:stop]
    end

    def logger
      Newflow.logger
    end

    private
      def check_validity
        raise "State #{name} cannot be both a start and a stop" if start? && stop?
      end
  end
end

