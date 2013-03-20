module Capnotify
  class ComponentList

    attr_reader :components

    def initialize
      @components = []
    end

    def <<(component)
      validate! component
      @components << component
    end

    def insert(index, component)
      validate! component
      components.insert(index,component)
    end

    def prepend(component)
      insert(0, component)
    end

    def append(component)
      self.<< component
    end

    private

    # component should be a Component
    # raise ArgumentError if not
    def validate!(component)
      raise ArgumentError, "You must pass a Capnotify::Component object! You passed a #{ component.class }" unless component.is_a?(Capnotify::Component)
    end

  end
end
