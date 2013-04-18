module Capnotify
  module Plugin
    module Details

      PLUGIN_NAME = :capnotify_details

      def init
        capnotify.components << Capnotify::Component.new(PLUGIN_NAME) do |c|
          c.header = 'Deployment Details'

          c.content = {}
          c.content['Branch'] = fetch(:branch, 'n/a')
          c.content['Sha1'] = fetch(:latest_revision, 'n/a')
          c.content['Release'] = fetch(:release_name, 'n/a')

          if fetch(:github_url, nil)
            c.content['WWW'] = "#{ fetch(:github_url) }/tree/#{ fetch(:latest_revision) }"
          end
        end
      end

      def unload
        capnotify.delete_component PLUGIN_NAME
      end

    end
  end
end
