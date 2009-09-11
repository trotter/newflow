module Newflow
  class Workflow
    def initialize(extendee)
      @extendee = extendee
    end

    def define_workflow
      raise "#{@extendee.class} needs to implement define_workflow"
    end

    def validate_workflow!
      # TODO: Validate that all transitions reach a valid state
      # TODO: Validate that there is at least one stop state
      raise "#{@extendee.class} needs at least two states" if states.size < 2
      raise "#{@extendee.class} needs a start of the workflow" unless current_state
    end

    def states
      @states ||= {}
    end

    def method_missing(name, *args, &block)
      if name.to_s =~ /\?$/
        state_name = name.to_s[/(.*)\?$/, 1].to_sym
        states.keys.detect{ |name| name == state_name }
        current_state == state_name
      else
        super
      end
    end

    def state(name, opts={}, &block)
      # TODO: Assert we're not overriding a state
      states[name] = State.new(name, opts, &block)
    end

    def construct_workflow!
      return true if @constructed
      @extendee.define_workflow
      start_state = states.values.detect { |s| s.start? }
      @extendee.workflow_state = start_state.name.to_s if start_state
      validate_workflow!
      @constructed = true
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

