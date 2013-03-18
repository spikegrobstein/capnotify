require 'spec_helper'

describe Capnotify do

  let(:config) do
    Capistrano::Configuration.new
  end

  before do
    Capnotify.load_into(config)
  end

  let(:capnotify) { config.capnotify }

  context "built-in callbacks" do

    context "deploy callbacks" do
      it "should trigger :deploy_start before deploy"

      it "should trigger :deploy_complete after deploy"
    end

    context "migration callbacks" do
      it "should trigger :migrate_start before deploy:migrate"

      it "should trigger :migrate_complete after deploy:migrate"
    end

    context "maintenance page callbacks" do
      it "should trigger :maintenance_page_up before deploy:web:disable"

      it "should trigger :maintenance_page_down after deploy:web:enable"
    end

  end

  context "built-in messages" do

    context "when application is not specified" do

      before do
        config.load do
          set :stage, 'production'
        end
      end

      it "should not raise an error" do
        lambda { config.capnotify_appname }.should_not raise_error
      end

    end

    context "when stage is not specified" do

      before do
        config.load do
          set :application, 'MyApp'
        end
      end

      it "should not raise an error" do
        lambda { config.capnotify_appname }.should_not raise_error
      end

    end

    context "when the user wants to override capnotify_appname" do
      before do
        config.load do
          set :capnotify_appname, 'SimpleApp'
        end
      end

      it "should return what the user overrode with" do
        config.capnotify_appname.should == 'SimpleApp'
      end

    end

    context "when both application and stage are specified" do

      before do
        config.load do
          set :application, 'SimpleApp'
          set :stage, 'production'
        end
      end

      it "should not raise an error" do
        lambda { config.capnotify_appname }.should_not raise_error
      end

      it "should include the application name" do
        config.capnotify_appname.should match('SimpleApp')
      end

      it "should include the stage name" do
        config.capnotify_appname.should match('production')
      end

    end

  end

end
