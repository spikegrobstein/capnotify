module Capnotify
  module Plugin
    class Overview

      @component_name = :capnotify_overview

      def initialize(config)

        config.load do
          on(:deploy_complete) do
            c = Capnotify::Component.new(@component_name, :header => 'Overview')

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

      def unload
        # capnotify
      end

    end
  end
end
