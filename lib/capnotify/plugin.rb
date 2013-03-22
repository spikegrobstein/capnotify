require 'capnotify/version'
require 'pry'

module Capnotify
  module Plugin

    # convenience method for getting the friendly app name
    # If the stage is specified (the deployment is using multistage), include that.
    # given that the application is "MyApp" and the stage is "production", this will return "MyApp production"
    def appname
      fetch(:capnotify_appname, "")
    end

    def load_plugin(name, mod)
      Capistrano.plugin name, mod
      # binding.pry

      get_plugin(name).init
    end

    def unload_plugin(name)
      # binding.pry
      p = get_plugin(name)

      p.unload if p.respond_to?(:unload)
      Capistrano.remove_plugin(name)
    end

    def get_plugin(name)
      raise "Unknown plugin: #{ name }" unless Capistrano::EXTENSIONS.keys.include?(name)
      self.send(name)
    end
    private :get_plugin

    # component stuff:

    # template stuff:

    # return the path to the built-in template with the given name
    def built_in_template_for(template_name)
      File.join( File.dirname(__FILE__), 'templates', template_name )
    end

    # given a path to an ERB template, process it with the current binding and return the output.
    def build_template(template_path)
      ERB.new( File.open( template_path ).read, nil, '<>' ).result(self.binding)
    end

    def components
      fetch(:capnotify_component_list)
    end

  end
end
