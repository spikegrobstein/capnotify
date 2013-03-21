require 'capnotify/version'

module Capnotify
  module Plugin

    # convenience method for getting the friendly app name
    # If the stage is specified (the deployment is using multistage), include that.
    # given that the application is "MyApp" and the stage is "production", this will return "MyApp production"
    def appname
      fetch(:capnotify_appname, "")
    end

    def load_plugin(plugin)
      capnotify_plugins[plugin] = plugin.new(@config)
    end

    def unload_plugin(plugin)
      capnotify_plugins[plugin].unload if capnotify_plugins[plugin].respond_to?(:unload)
      capnotify_plugins.delete(plugin)
    end

    # component stuff:

    # template stuff:

    # return the path to the built-in template with the given name
    def built_in_template_for(template_name)
      File.join( File.dirname(__FILE__), 'templates', template_name )
    end

    # given a path to an ERB template, process it with the current binding and return the output.
    def build_template(template_path)
      ERB.new( File.open( template_path ).read ).result(self.binding)
    end

    def components
      fetch(:capnotify_component_list)
    end

  end
end
