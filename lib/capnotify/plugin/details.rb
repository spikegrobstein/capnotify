module Capnotify
  module Plugin
    module Details

      def init
        capnotify.components << Capnotify::Component.new(:capnotify_details) do |c|
          c.header = 'Details'

          c.content = {}
          c.content['Branch'] = fetch(:branch, 'n/a')
          c.content['Sha1'] = fetch(:latest_revision, 'n/a')
          c.content['Release'] = fetch(:release_name, 'n/a')

          if fetch(:github_url, nil)
            c.content['WWW'] = "#{ fetch(:github_url) }/tree/#{ fetch(:latest_revision) }"
          end
        end
      end

    end
  end
end
