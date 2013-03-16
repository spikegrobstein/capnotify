require 'capnotify/version'

module Capnotify
  module Plugin
    def appname
      [ fetch(:application, nil), fetch(:stage, nil) ].compact.join(" ")
    end

    def built_in_template_for(template)
      File.join( File.dirname(__FILE__), 'templates', template )
    end

    def build_template(template_path)
      ERB.new( File.open( template_path ).read ).result(self.binding)
    end
  end
end
