module Newflow
  class Trigger
    def initialize(trigger)
      @trigger = trigger
    end

    def run!(workflow)
      return false unless @trigger
      case @trigger
      when Symbol
        workflow.send(@trigger)
      when Array
        @trigger.each {|t| Trigger.new(t).run!(workflow) }
      else
        @trigger.call
      end
    end
  end
end

