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

    PLUGIN_NAME = :my_plugin

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

  after do
    Capistrano::EXTENSIONS.keys.each do |ex|
      Capistrano.remove_plugin(ex)
    end
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
        capnotify.load_plugin MyPlugin
      end

      Capistrano::EXTENSIONS.keys.should include(:my_plugin)
    end

    it "should call init on the plugin" do
      ProxyObject.instance.should_receive :call_init

      config.load do
        capnotify.load_plugin MyPlugin
      end

    end

  end

  context "#unload_plugin" do

    before do
      config.load do
        capnotify.load_plugin MyPlugin
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
          capnotify.load_plugin MyPlugin
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

    context "when building templates with components" do

      let(:html_rendered_template) { capnotify.build_template( capnotify.built_in_template_for('default_notification.html.erb') ) }
      let(:text_rendered_template) { capnotify.build_template( capnotify.built_in_template_for('default_notification.txt.erb') ) }

      before do
        capnotify.load_default_plugins
        capnotify.components.count.should > 0
      end

      context "html templates" do
        it "should not render components with no content" do
          html_rendered_template.should_not match(/Message/) # the header
        end

        it "should render components with content" do
          config.set :notification_msg, 'ASDFASDF'

          html_rendered_template.should match(/Message/) # the header
          html_rendered_template.should match(/ASDFASDF/) # the content
        end
      end

      context "text templates" do
        it "should not render components with no content" do
          text_rendered_template.should_not match(/Message/) # the header
        end

        it "should render components with content" do
          config.set :notification_msg, 'ASDFASDF'

          text_rendered_template.should match(/Message/) # the header
          text_rendered_template.should match(/ASDFASDF/) # the content
        end
      end

    end

  end

  context "#components" do
    it "should return the components" do
      capnotify.components.should === config.fetch(:capnotify_component_list)
    end
  end

  context "#component" do
    let!(:component) { Capnotify::Component.new(:test_component) }

    before do
      4.times do |i|
        capnotify.components << Capnotify::Component.new("component_#{ i }")
      end

      capnotify.components << component
    end

    it "should return the component with the given name" do
      capnotify.component(:test_component).should === component
    end

    it "should return nil if the requested component does not exist" do
      capnotify.component(:fake_component).should be_nil
    end
  end

  context "inserting components" do
    let!(:component) { Capnotify::Component.new(:test_component) }

    before do
      capnotify.components.clear

      # add components 0 - 3
      4.times do |i|
        capnotify.components << Capnotify::Component.new("component_#{ i }")
      end
    end

    context "before" do

      it "should insert the given component" do
        expect { capnotify.insert_component_before(:component_2, component) }.to change { capnotify.components.count }.by(1)
      end

      it "should insert the given component in the correct place" do
        capnotify.insert_component_before(:component_2, component)

        capnotify.components.map(&:name)[2].should == component.name
      end

      it "should insert the component at the end if no component with given name exists" do
        capnotify.insert_component_before(:this_component_does_not_exist, component)

        capnotify.components.last.name.should == component.name
      end

    end

    context "after" do

      it "should insert the given component" do
        expect { capnotify.insert_component_after(:component_2, component) }.to change { capnotify.components.count }.by(1)
      end

      it "should insert the given component in the correct place" do
        capnotify.insert_component_after(:component_2, component)

        capnotify.components.map(&:name)[3].should == component.name
      end

      it "should insert the component at the end if no component with given name exists" do
        capnotify.insert_component_after(:this_component_does_not_exist, component)

        capnotify.components.last.name.should == component.name
      end
    end

  end

  context "#delete_component" do
    let!(:component) { Capnotify::Component.new(:test_component) }

    before do
      4.times do |i|
        capnotify.components << Capnotify::Component.new("component_#{ i }")
      end

      capnotify.components << component
    end

    it "should not error out if you delete a non-existent component" do
      lambda { capnotify.delete_component(:fake_component) }.should_not raise_error
    end

    it "should delete the given component" do
      expect { capnotify.delete_component(:test_component) }.to change { capnotify.components.length }.by(-1)
    end

    it "should return the given deleted component" do
      capnotify.delete_component(:test_component).should === capnotify.components
    end
  end
end
