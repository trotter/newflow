require 'logger'

# Require all the files
base_dir = File.dirname(__FILE__) + "/newflow"
Dir["#{base_dir}/*.rb"].each { |f| require f }

# TODO: Allow workflows to identify themselves (for logging and stuffs)
module Newflow
  def self.logger
    return @logger if @logger
    @logger = if defined?(Rails)
                Rails.logger
              else
                Logger.new($stderr)
              end
  end

  def define_workflow
    raise "#{self.class} needs to implement define_workflow"
  end

  def validate_workflow!
    # TODO: Validate that all transitions reach a valid state
    # TODO: Validate that there is at least one stop state
    raise "#{self.class} needs at least two states" if states.size < 2
    raise "#{self.class} needs a start of the workflow" unless current_state
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
    define_workflow
    start_state = states.values.detect { |s| s.start? }
    self.workflow_state = start_state.name.to_s if start_state
    validate_workflow!
    @constructed = true
  end

  def transition_once!
    state = states[current_state]
    self.workflow_state = state.run(self).to_s
  end

  def transition!
    # TODO: watch out for max # of transits
    begin
      the_state = current_state
      transition_once!
    end while the_state != current_state && states[current_state]
  end

  def current_state
    workflow_state.to_sym
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

