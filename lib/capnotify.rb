require "capnotify/version"
require 'capnotify/component'
require 'capnotify/component_list'
require 'capnotify/plugin'

module Capnotify
  def self.load_into(config)
    config.load do
      Capistrano.plugin :capnotify, ::Capnotify::Plugin

      def _cset(name, *args, &block)
        unless exists?(name)
          set(name, *args, &block)
        end
      end


      # some configuration
      _cset :capnotify_deployment_notification_html_template_path, capnotify.built_in_template_for('default_notification.html.erb')
      _cset :capnotify_deployment_notification_text_template_path, capnotify.built_in_template_for('default_notification.txt.erb')

      _cset(:deployer_username) do
        if exists?(:scm) && fetch(:scm).to_sym == :git
          `git config user.name`.chomp
        else
          `whoami`.chomp
        end
      end

      # built-in values:

      # override this to change the default behavior for capnotify.appname
      _cset(:capnotify_appname) do
        [ fetch(:application, nil), fetch(:stage, nil) ].compact.join(" ")
      end

      # default messages:
      # (these can be overridden)

      # short message for the start of running migrations
      _cset(:capnotify_migrate_start_msg) do
        "#{ capnotify.appname } migration starting."
      end

      # short message for the completion of running migrations
      _cset(:capnotify_migrate_complete_msg) do
        "#{ capnotify.appname } migration completed."
      end

      # short message for the start of a deployment
      _cset(:capnotify_deploy_start_msg) do
        "#{ capnotify.appname } deployment completed."
      end

      # short message for the completion of a deployment
      _cset(:capnotify_deploy_complete_msg) do
        "#{ capnotify.appname } deployment completed."
      end

      # short message for putting up a maintenance page
      _cset(:capnotify_maintenance_up_msg) do
        "#{ capnotify.appname } maintenance page is now up."
      end

      # short message for taking down a maintenance page
      _cset(:capnotify_maintenance_down_msg) do
        "#{ capnotify.appname } maintenance page has been taken down."
      end

      # full email message to notify of deployment (html)
      _cset(:capnotify_deployment_notification_html) do
        capnotify.build_template( fetch(:capnotify_deployment_notification_html_template_path) )
      end

      # full email message to notify of deployment (plain text)
      _cset(:capnotify_deployment_notification_text) do
        data = capnotify.build_template( fetch(:capnotify_deployment_notification_text_template_path) )

        # clean up the text output (remove leading spaces and more than 2 newlines in a row
        data.gsub(/^ +/, '').gsub(/\n{3,}/, "\n\n")
      end

      # configure the callbacks

      # deploy start/complete
      before('deploy') { trigger :deploy_start }
      after('deploy')  { trigger :deploy_complete }

      # migration start/complete
      before('deploy:migrate') { trigger :migrate_start }
      after('deploy:migrate')  { trigger :migrate_complete }

      # maintenance start/complete
      after('deploy:web:disable') { trigger :maintenance_page_up }
      after('deploy:web:enable')  { trigger :maintenance_page_down }

      # before update_code, fetch the current revision
      # this is needed to ensure that no matter when capnotify fetches the commit logs,
      # it will have the correct starting point.
      before 'deploy:update_code' do
        set :capnotify_previous_revision, fetch(:current_revision, nil) # the revision that's currently deployed at this moment
      end

    end
  end

end

if Capistrano::Configuration.instance
  Capnotify.load_into(Capistrano::Configuration.instance)
end

