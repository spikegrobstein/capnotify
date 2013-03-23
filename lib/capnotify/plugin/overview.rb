module Capnotify
  module Plugin
    module Overview

      def init
        capnotify.components << Capnotify::Component.new(:capnotify_overview) do |c|
          c.header = 'Deployment Overview'

          c.content = {}
          c.content['Deployed by'] = 'capnotify.deployed_by'
          c.content['Deployed at'] = Time.now
          c.content['Application'] = fetch(:application, '')
          c.content['Repository'] = fetch(:repository, '')
        end
      end

      def unload
        capnotify.components.delete_if { |p| p.name == :capnotify_overview }
      end

    end
  end
end
