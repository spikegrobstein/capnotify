module Capnotify
  module Plugin
    module Message

      PLUGIN_NAME = :capnotify_message

      def init
        capnotify.components << Capnotify::Component.new(PLUGIN_NAME) do |c|
          c.header = 'Message'

          c.content = fetch(:notification_msg, nil)
        end
      end

      def unload
        capnotify.delete_component PLUGIN_NAME
      end

    end
  end
end
