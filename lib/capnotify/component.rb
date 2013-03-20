module Capnotify
  class Component

    # content can only be of these types of classes
    VALID_CONTENT_CLASSES = [ String, Hash, Array ]

    attr_accessor :header, :name, :css_class
    attr_reader :content

    def initialize(name, options={})
      @name = name.to_sym

      @header = options[:header]
      @css_class = options[:css_class]
    end

    def content=(new_content)
      raise ArgumentError, "content must be a #{ VALID_CONTENT_CLASSES.join(', ') }" unless VALID_CONTENT_CLASSES.include?(new_content.class)

      @content = new_content
    end
  end
end
