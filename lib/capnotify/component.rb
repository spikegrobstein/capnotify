module Capnotify
  class Component

    class TemplateUndefined < StandardError; end

    attr_accessor :header, :name

    # the class(s) for this component (as a string)
    attr_accessor :css_class, :custom_css

    # a block that will configure this instance lazily
    attr_reader :builder

    attr_accessor :template_path, :renderers

    attr_accessor :config


    def initialize(name, options={}, &block)
      @name = name.to_sym

      # default stuff
      @template_path = File.join( File.dirname(__FILE__), 'templates' )

      @renderers = {
        :html => '_component.html.erb',
        :txt => '_component.txt.erb'
      }

      @header = options[:header]
      @css_class = options[:css_class] || 'section'
      @custom_css = options[:custom_css]

      if block_given?
        @builder = block
      end
    end

    # assign the content as new_content
    def content=(new_content)
      @content = new_content
    end

    def content
      @content
    end

    # FIXME: this should probably leverage Procs for rendering of different types, maybe?
    #        that would give a lot of power to a developer who wants a custom format for a plugin (eg XML or JSON)
    # Render the content in the given format using the right built-in template. Returns the content as a string.
    # In the event that there is not a valid template, return an empty string.
    def render_content(format)
      begin
        ERB.new( File.open( template_path_for(format) ).read, nil, '%<>' ).result(self.get_binding)
      rescue TemplateUndefined
        ''
      end
    end

    # return the binding for this object
    # this is needed when embedding ERB templates in each other
    def get_binding
      binding
    end

    # set the template path for this particular instance
    # the template path is the path to the parent directory of a renderer ERB template
    def template_path_for(format)
      raise TemplateUndefined, "Template for #{ format } is missing!" if @renderers[format].nil?

      File.join( @template_path, @renderers[format] )
    end

    # create renderers
    # given a key for the format, provide the name of the ERB template to use to render relative to the template path
    def render_for(renderers={})
      @renderers = @renderers.merge(renderers)
    end

    # call @builder with self as a param if @builder is present
    # ensure builder is nil
    # then return self
    def build!(config)
      @builder.call(self) unless @builder.nil?

      @builder = nil
      @config = config

      return self
    end
  end
end
