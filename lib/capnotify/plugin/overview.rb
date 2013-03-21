module Capnotify
  module Plugin
    class Overview

      def initialize(config)

        config.load do
          on(:deploy_complete) do
            c = Capnotify::Component.new(:capnotify_overview, :header => 'Overview')

            c.content = {
              'Deployed by' => 'insert username',
              'Deployed at' => Time.now,
              'Application' => fetch(:application, ''),
              'Repository' => fetch(:repository, '')
            }

            capnotify.components << c
          end
        end

      end

    end
  end
end
