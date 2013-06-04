# Capnotify built-in plugin for Custom messages in email
# This adds a "message" section that will include 'notification_msg' if it's set
# For example:
#  cap deploy -s notification_msg="Just getting a hotfix deployed"
module Capnotify
  module Plugin
    module Message

      # the plugin's name (how it's referenced once it's loaded)
      PLUGIN_NAME = :capnotify_message

      # initialize the plugin
      def init
        # add a component tagged with this plugin's name
        capnotify.components << Capnotify::Component.new(PLUGIN_NAME) do |c|
          # the header
          c.header = 'Message'

          # the content
          # if notification_msg isn't set, content will be set to nil
          # nil content will prevent the section from being rendered.
          c.content = fetch(:notification_msg, nil)
        end
      end

      # delete the component when this plugin is unloaded
      def unload
        capnotify.delete_component PLUGIN_NAME
      end

    end
  end
end
