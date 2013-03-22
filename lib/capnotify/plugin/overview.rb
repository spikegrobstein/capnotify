module Capnotify
  module Plugin
    module Overview

      def init
        before(:deploy) do
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

      def unload
        capnotify.components.delete_if { |p| p.name == :capnotify_overview }
      end

    end
  end
end
