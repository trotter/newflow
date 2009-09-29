module Newflow
  class Transition
    attr_reader :target_state, :predicate, :predicate_name, :trigger

    def initialize(target_state,opts)
      @target_state = target_state
      if_meth      = opts[:if]
      unless_meth  = opts[:unless]
      @trigger      = Trigger.new(opts[:trigger])
      logger.debug "State.transitions_to: target_state=#{target_state} if=#{if_meth.inspect} unless=#{unless_meth.inspect} trigger=#{@trigger}"
      unless @target_state \
          &&  (if_meth || unless_meth) \
          && !(if_meth && unless_meth) 
        raise "You must specify a target state(#@target_state) and (if_method OR unless_method)" 
      end
      @predicate_name = (if_meth || "!#{unless_meth}").to_s
      @predicate = if if_meth
                     # TODO: be smart
                     if if_meth.respond_to?(:call)
                       lambda { |wf| if_meth.call }
                     else
                       lambda { |wf| wf.send(if_meth) }
                     end
                   else
                     if unless_meth.respond_to?(:call)
                       lambda { |wf| !unless_meth.call }
                     else
                       lambda { |wf| !wf.send(unless_meth) }
                     end
                   end
    end

    def can_transition?(workflow)
      predicate.call(workflow)
    end

    def trigger!(workflow)
      trigger.run!(workflow)
    end

    def logger
      Newflow.logger
    end
  end
end

