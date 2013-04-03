require 'spec_helper'

describe Capnotify do

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

  context "loading" do
    it "should initialize capnotify.components" do
      capnotify.components.should_not be_nil
    end
  end

  context "built-in callbacks" do

    before do
      # there has to be a better way of doing this...
      # create a MockObject to handle the callbacks
      class MockObject
      end
      MockObject.stub!(:deploy_start => true)
      MockObject.stub!(:deploy_complete => true)
      MockObject.stub!(:migrate_start => true)
      MockObject.stub!(:migrate_complete => true)
      MockObject.stub!(:maintenance_page_up => true)
      MockObject.stub!(:maintenance_page_down => true)

      config.load do
        # these don't get triggered unless something is defined.
        on(:deploy_start) { MockObject.deploy_start }
        on(:deploy_complete) { MockObject.deploy_complete }
        on(:migrate_start) { MockObject.migrate_start }
        on(:migrate_complete) { MockObject.migrate_complete }
        on(:maintenance_page_up) { MockObject.maintenance_page_up }
        on(:maintenance_page_down) { MockObject.maintenance_page_down }

        # stub some tasks
        namespace :deploy do
          task(:default) {}
          task(:migrate) {}
          namespace :web do
            task(:enable) {}
            task(:disable) {}
          end
        end
      end

      config.trigger(:load)
    end

    context "deploy callbacks" do
      it "should trigger :deploy_start before deploy" do
        MockObject.should_receive(:deploy_start)
        config.find_and_execute_task('deploy')
      end

      it "should trigger :deploy_complete after deploy" do
        MockObject.should_receive(:deploy_complete)
        config.find_and_execute_task('deploy')
      end
    end

    context "migration callbacks" do
      it "should trigger :migrate_start before deploy:migrate" do
        MockObject.should_receive(:migrate_start)
        config.find_and_execute_task('deploy:migrate')
      end

      it "should trigger :migrate_complete after deploy:migrate" do
        MockObject.should_receive(:migrate_complete)
        config.find_and_execute_task('deploy:migrate')
      end
    end

    context "maintenance page callbacks" do
      it "should trigger :maintenance_page_up before deploy:web:disable" do
        MockObject.should_receive(:maintenance_page_up)
        config.find_and_execute_task('deploy:web:disable')
      end

      it "should trigger :maintenance_page_down after deploy:web:enable" do
        MockObject.should_receive(:maintenance_page_down)
        config.find_and_execute_task('deploy:web:enable')
      end
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
        config.capnotify_appname.should match(/SimpleApp/)
      end

      it "should include the stage name" do
        config.capnotify_appname.should match(/production/)
      end

      context "when the branch is not specified" do

        it "should only include the app and stage name" do
          config.capnotify_appname.split(/\s/).count.should == 2 # should only have 2 words in it
          config.capnotify_appname.should_not match(/\//) # should not have a slash
        end

      end

      context "when the branch is specified" do

        before do
          config.set :branch, 'mybranch'
        end

        it "should include the application name" do
          config.capnotify_appname.should match(/SimpleApp/)
        end

        it "should include the stage name" do
          config.capnotify_appname.should match(/production/)
        end

        it "should contain the branch name" do
          config.capnotify_appname.should match(/mybranch/)
        end

      end

    end

  end

  context "capnotify_disable_default_components" do

    context "when it is set to true" do

      before do
        config.load do
          set :capnotify_disable_default_components, true
        end
      end

      it "should not have any plugins loaded by default" do
        config.trigger(:load)
        Capistrano::EXTENSIONS.keys.map(&:to_s).grep(/^capnotify_/).count.should == 0
      end

    end

    context "when it is not set" do

      it "should have defauilt plugins loaded by default" do
        config.trigger(:load)
        Capistrano::EXTENSIONS.keys.map(&:to_s).grep(/^capnotify_/).count.should > 0
      end
    end
  end

end
