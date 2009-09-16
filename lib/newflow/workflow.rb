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

    def transition_once!(do_trigger=Newflow::WITH_SIDE_EFFECTS)
      state = states[current_state]
      raise "'#{current_state}' is not a valid state" unless state # TODO: TEST
      @extendee.workflow_state = state.run(@extendee, do_trigger).to_s
    end

    def transition!(do_trigger=Newflow::WITH_SIDE_EFFECTS)
      # TODO: watch out for max # of transits
      previous_state = current_state
      previous_states = {}
      num_transitions = 0
      begin
        if previous_states[current_state]
          raise "Error: possible [infinite] loop in workflow, started in: #{previous_state}, currently in #{current_state}, been through all of (#{previous_states.keys.map(&:to_s).sort.join(", ")})" # TODO: TEST
        end
        previous_states[current_state] = true
        the_state = current_state
        transition_once!(do_trigger)
      end while the_state != current_state && states[current_state]
      previous_state == current_state ? nil : current_state
    ensure
      @extendee.workflow_state = previous_state unless do_trigger
    end

    def would_transition_to
      transition!(Newflow::WITHOUT_SIDE_EFFECTS)
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

