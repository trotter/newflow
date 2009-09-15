module Newflow
  class Workflow
    def initialize(extendee, definition)
      @extendee = extendee
      construct_workflow!(definition)
    end

    def validate_workflow!
      # TODO: Validate that all transitions reach a valid state
      # TODO: Validate that there is at least one stop state
      raise InvalidStateDefinitionError.new("#{@extendee.class} needs at least two states") if states.size < 2
      raise InvalidStateDefinitionError.new("#{@extendee.class} needs a start of the workflow") unless current_state
    end

    def states
      @states ||= {}
    end

    def state(name, opts={}, &block)
      # TODO: Assert we're not overriding a state
      states[name] = State.new(name, opts, &block)
    end

    def construct_workflow!(definition)
      instance_eval &definition
      start_state = states.values.detect { |s| s.start? }
      @extendee.workflow_state = start_state.name.to_s if start_state
      validate_workflow!
      define_state_query_methods
    end

    def define_state_query_methods
      states.keys.each do |key|
        instance_eval <<-EOS
          def #{key}?; current_state == :#{key}; end
        EOS
      end
    end

    def transition_once!
      state = states[current_state]
      @extendee.workflow_state = state.run(@extendee).to_s
    end

    def transition!
      # TODO: watch out for max # of transits
      begin
        the_state = current_state
        transition_once!
      end while the_state != current_state && states[current_state]
    end

    def current_state
      @extendee.workflow_state.to_sym
    end

    def current_state=(state)
      @extendee.workflow_state = state.to_s
    end

    def to_dotty
      dot = ""
      dot << "digraph {\n"
      states.keys.each { |state_name|
        state = states[state_name]
        # it'd be nice to have the current state somehow shown visually
        shape = "circle"
        if state_name == current_state
          puts "setting current shape to doublecircle #{state_name} vs #{current_state}"
          shape = "doublecircle"
        end
        dot << %Q[  "#{state_name}" [ shape = #{shape} ]; \n]
        state.transitions.each { |transition|
          dot << "  \"#{state_name}\" -> \"#{transition.target_state}\" [ label = \"#{transition.predicate_name}\" ];\n"
        }
      }
      dot << "}\n"
      return dot
    end
  end
end

