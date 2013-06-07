require 'capnotify/version'
require 'pry'

module Capnotify
  module Plugin

    # output a pretty splash screen of the Capnotify logo
    # this can be enabled by setting capnotify_show_splash to a truthy value:
    #  set :capnotify_show_splash, true
    def print_splash
      puts <<-SPLASH
           __________________
      - --|\\   Deployment   /|    _____                    __  _ ___
     - ---| \\   Complete   / |   / ___/__ ____  ___  ___  / /_(_) _/_ __
    - ----| /\\____________/\\ |  / /__/ _ `/ _ \\/ _ \\/ _ \\/ __/ / _/ // /
   - -----|/ - Capistrano - \\|  \\___/\\_,_/ .__/_//_/\\___/\\__/_/_/ \\_, /
  - ------|__________________|          /_/                      /___/

      SPLASH
    end

    # convenience method for getting the friendly app name
    # If the stage is specified (the deployment is using multistage), include that.
    # given that the application is "MyApp" and the stage is "production", this will return "MyApp production"
    # if capnotify_appname is not set, it'll return an empty string
    def appname
      fetch(:capnotify_appname, "")
    end

    # get the name of the deploying user
    # currently this only supports git.
    # if reading the git user.name, fall back on `whoami`
    def deployed_by
      username = nil

      scm = fetch(:scm, nil)

      if scm
        if scm.to_sym == :git
          username = `git config user.name`.chomp
          username = nil if $? != 0 || username.strip == ''
        end
      end

      username || `whoami`.chomp
    end

    # load the default built-in plugins
    # this is called automatically when capistrano is done loading
    # you can disable this (and not laod any plugins by default) by setting capnotify_disable_default_components
    #  set :capnotify_disable_default_components, true
    def load_default_plugins
      capnotify.load_plugin Capnotify::Plugin::Message
      capnotify.load_plugin Capnotify::Plugin::Overview
      capnotify.load_plugin Capnotify::Plugin::Details
    end

    # given a module name, load it as a plugin
    # capnotify plugins must conform to the spec. See docs for info.
    # mod should be the module itself, eg:
    #  capnotify.load_plugin Capnotify::Plugin::Message
    def load_plugin(mod)
      Capistrano.plugin mod::PLUGIN_NAME, mod

      get_plugin(mod::PLUGIN_NAME).init
    end

    # given a plugin name as a symbol, unload the capnotify plugin
    # this will also unload any kind of capistrano plugin
    # if the plugin supports the unload method, it will be called.
    def unload_plugin(name)
      p = get_plugin(name)

      p.unload if p.respond_to?(:unload)
      Capistrano.remove_plugin(name)
    end

    # given a plugin name, return the plugin.
    def get_plugin(name)
      raise "Unknown plugin: #{ name }" unless Capistrano::EXTENSIONS.keys.include?(name)
      self.send(name)
    end
    private :get_plugin

    # template stuff:

    # return the path to the built-in template with the given name
    def built_in_template_for(template_name)
      File.join( File.dirname(__FILE__), 'templates', template_name )
    end

    # given a path to an ERB template, process it with the current binding and return the output.
    def build_template(template_path)
      # FIXME: this is called every time build_template is called.
      # although this is idepodent, it's got room for optimization
      self.build_components!

      ERB.new( File.open( template_path ).read, nil, '<>' ).result(self.binding)
    end

    # component stuff

    # returns the capnotify_component_list
    # this is the underlying mechanism for working with components
    # append or prepend or insert from here.
    def components
      fetch(:capnotify_component_list)
    end

    # fetch a component given the name
    # this is most useful for getting a component directly if you want to make modificatins to it
    def component(name)
      components.each { |c| return c if c.name == name.to_sym }
      return nil
    end

    # insert the given component before the component with `name`
    # if no component is found with that name, the component will be inserted at the end
    def insert_component_before(name, component)
      # iterate over all components, find the component with the given name
      # once found, insert the given component at that location and return
      components.each_with_index do |c, i|
        if c.name == name
          components.insert(i, component)
          return
        end
      end

      components << component
    end

    # insert the given component after the component with `name`
    # if no component is found with that name, the component will be inserted at the end
    def insert_component_after(name, component)
      # iterate over all components, find the component with the given name
      # once found, insert the given component at the following location and return
      components.each_with_index do |c, i|
        if c.name == name
          components.insert(i + 1, component)
          return
        end
      end

      components << component
    end

    # delete the component with the given name
    # return the remaining list of components (to enable chaining)
    def delete_component(name)
      components.delete_if { |c| c.name == name.to_sym }
    end

    # build all components
    def build_components!
      set :capnotify_component_list, self.components.map { |c| c.build!(self) }
    end

  end
end
