module Capnotify
  module Plugin
    module Details

      def init
        before(:deploy) do
          c = Capnotify::Component.new(:capnotify_details, :header => 'Details')

          c.content = {
            'Branch' => fetch(:branch, 'n/a'),
            'Sha1' => fetch(:latest_revision, 'n/a'),
            'Release' => fetch(:release_name, 'n/a')
          }

          if fetch(:github_url, nil)
            c.content['WWW'] = "#{ fetch(:github_url) }/tree/#{ fetch(:latest_revision) }"
          end

          capnotify.components << c
        end
      end

    end
  end
end
