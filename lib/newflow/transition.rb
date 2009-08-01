module Newflow
  class Transition
    attr_reader :target_state, :predicate, :predicate_name, :trigger
    def initialize(target_state,opts)
      @target_state = target_state
      if_meth      = opts[:if]
      unless_meth  = opts[:unless]
      @trigger      = opts[:trigger]
      logger.debug "State.transitions_to: target_state=#{target_state} if=#{if_meth.inspect} unless=#{unless_meth.inspect} trigger=#{@trigger}"
      unless @target_state \
          &&  (if_meth || unless_meth) \
          && !(if_meth && unless_meth) 
        raise "You must specify a target state(#@target_state) and (if_method OR unless_method)" 
      end
      @predicate_name = if_meth || "!#{unless_meth}"
      @predicate = if if_meth
                     # TODO: be smart
                     if if_meth.is_a?(Symbol)
                       lambda { |wf| wf.send(if_meth) }
                     else
                       lambda { |wf| if_meth.call }
                     end
                   else
                     if unless_meth.is_a?(Symbol)
                       lambda { |wf| !wf.send(unless_meth) }
                     else
                       lambda { |wf| !unless_meth.call }
                     end
                   end
    end

    def can_transition?(workflow)
      predicate.call(workflow)
    end

    def trigger!(workflow)
      return false unless trigger
      if trigger.is_a?(Symbol)
        workflow.send(trigger)
      else
        trigger.call
      end
    end

    def logger
      Newflow.logger
    end
  end
end

