module Capnotify
  class Component

    # content can only be of these types of classes
    VALID_CONTENT_CLASSES = [ String, Hash, Array ]

    attr_accessor :header, :name

    # the class(s) for this component (as a string)
    attr_accessor :css_class, :custom_css

    # a block that will configure this instance lazily
    attr_reader :builder

    def initialize(name, options={}, &block)
      @name = name.to_sym

      @header = options[:header]
      @css_class = options[:css_class] || 'section'
      @custom_css = options[:custom_css]

      if block_given?
        @builder = block
      end
    end

    # assign the content as new_content
    def content=(new_content)
      raise ArgumentError, "content must be a #{ VALID_CONTENT_CLASSES.join(', ') }" unless VALID_CONTENT_CLASSES.include?(new_content.class)

      @content = new_content
    end

    def content(format=:txt)
      @content
    end

    # call @builder with self as a param if @builder is present
    # ensure builder is nil
    # then return self
    def build!
      @builder.call(self) unless @builder.nil?

      @builder = nil

      return self
    end
  end
end
