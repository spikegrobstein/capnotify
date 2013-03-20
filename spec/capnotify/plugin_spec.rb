require 'spec_helper'

describe Capnotify::Plugin do

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

  context "#build_template" do

    it "should not error when using a built-in html template" do
      lambda { capnotify.build_template( capnotify.built_in_template_for('default_notification.html.erb') ) }.should_not raise_error
    end

    it "should not error when using a built-in text template" do
      lambda { capnotify.build_template( capnotify.built_in_template_for('default_notification.txt.erb') ) }.should_not raise_error
    end

  end

  context "#components"
end
