module Capnotify
  module Plugin
    module Message

      def init
        capnotify.components << Capnotify::Component.new(:capnotify_message) do |c|
          c.header = 'Message'

          c.content = fetch(:notification_msg, nil)
        end
      end

      def unload
        capnotify.delete_component :capnotify_message
      end

    end
  end
end
