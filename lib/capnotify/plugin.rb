require 'capnotify/version'

module Capnotify
  module Plugin
    # convenience method for getting the friendly app name
    # If the stage is specified (the deployment is using multistage), include that.
    # given that the application is "MyApp" and the stage is "production", this will return "MyApp production"
    def appname
      fetch(:capnotify_appname, "")
    end

    # commit log:
    # based on what SCM is currently being used
    def commit_log(first_ref, last_ref)
      case fetch(:scm, '')
      when :git
        git_commit_log
      else
        [ [ 'n/a', 'Log output not available (unsupported SCM).' ] ]
      end
    end

    def git_commit_log(first_ref, last_ref)
      return @log_output unless @log_output.nil?

      begin
        raise "Ref missing" if first_ref.nil? || last_ref.nil? # jump to resque block.

        log_output = run_locally("git log --oneline #{ first_ref }..#{ last_ref }")

        @log_output = log_output = log_output.split("\n").map do |line|
          fields = line.split("\s", 2)
          [ fields[0], fields[1] ]
        end
      rescue
        [ [ 'n/a', 'Log output not available.' ] ]
      end
    end

    # template stuff:

    # return the path to the built-in template with the given name
    def built_in_template_for(template_name)
      File.join( File.dirname(__FILE__), 'templates', template_name )
    end

    # given a path to an ERB template, process it with the current binding and return the output.
    def build_template(template_path)
      ERB.new( File.open( template_path ).read ).result(self.binding)
    end

  end
end
