require 'spec_helper'

describe Capnotify::Plugin do

  # a proxy object to call methods on to detect what gets called in the plugin
  class ProxyObject
    class << self
      @instance = nil
    end

    def self.instance
      @instance ||= ProxyObject.new
    end

    def call_init; end
    def call_unload; end
  end

  # a plugin for testing with
  # wires up init and unload to the ProxyObject
  module MyPlugin
    def init
      ProxyObject.instance.call_init
    end

    def unload
      ProxyObject.instance.call_unload
    end
  end

  let(:config) do
    Capistrano::Configuration.new
  end

  before do
    Capnotify.load_into(config)
  end

  let(:capnotify) { config.capnotify }

  context "#appname" do

    context "when capnotify_appname is missing" do

      before do
        config.load do
          unset :capnotify_appname
        end
      end

      it "should return an empty string" do
        capnotify.appname.should == ''
      end
    end

  end

  context "#load_plugin" do

    it "should load the plugin into capistrano" do
      config.load do
        capnotify.load_plugin :my_plugin, MyPlugin
      end

      Capistrano::EXTENSIONS.keys.should include(:my_plugin)
    end

    it "should call init on the plugin" do
      ProxyObject.instance.should_receive :call_init

      config.load do
        capnotify.load_plugin :my_plugin, MyPlugin
      end

    end

  end

  context "#unload_plugin" do

    before do
      config.load do
        capnotify.load_plugin :my_plugin, MyPlugin
      end
    end

    it "should call unload on the plugin if the plugin handles it" do
      ProxyObject.instance.should_receive(:call_unload)

      config.load do
        capnotify.unload_plugin :my_plugin
      end
    end

    it "should not blow up if the plugin does not handle #unload" do
      MyPlugin.send(:undef_method, :unload)

      lambda do
        config.load do
          capnotify.unload_plugin :my_plugin
        end
      end.should_not raise_error
    end

  end

  context "#get_plugin" do

    context "when plugin exists" do
      before do
        config.load do
          capnotify.load_plugin :my_plugin, MyPlugin
        end
      end

      it "should return the plugin" do
        capnotify.send(:get_plugin, :my_plugin).should_not be_nil
      end

      it "should not raise an error" do
        lambda { capnotify.send(:get_plugin, :my_plugin) }.should_not raise_error
      end

    end

    context "when the plugin does not exist" do

      it "should raise an error" do
        lambda { capnotify.send(:get_plugin, :does_not_exist) }.should raise_error
      end

    end

  end

  context "#build_template" do

    it "should not error when using a built-in html template" do
      lambda { capnotify.build_template( capnotify.built_in_template_for('default_notification.html.erb') ) }.should_not raise_error
    end

    it "should not error when using a built-in text template" do
      lambda { capnotify.build_template( capnotify.built_in_template_for('default_notification.txt.erb') ) }.should_not raise_error
    end

  end

  context "#components" do

  end
end
