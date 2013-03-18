require 'spec_helper'

describe Capnotify do

  let(:config) do
    Capistrano::Configuration.new
  end

  before do
    Capnotify.load_into(config)

    # default capistrano config
    config.load do
      set :application, 'testapp'
    end

    RestClient.stub(:post)
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

end
