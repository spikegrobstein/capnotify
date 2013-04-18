module Capnotify
  module Plugin
    module Overview

      PLUGIN_NAME = :capnotify_overview

      def init
        capnotify.components << Capnotify::Component.new(PLUGIN_NAME) do |c|
          c.header = 'Deployment Overview'

          c.content = {}
          c.content['Deployed by'] = 'capnotify.deployed_by'
          c.content['Deployed at'] = Time.now
          c.content['Application'] = fetch(:application, '')
          c.content['Repository'] = fetch(:repository, '')
        end
      end

      def unload
        capnotify.delete_component PLUGIN_NAME
      end

    end
  end
end
