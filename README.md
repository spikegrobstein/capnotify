# Capnotify

abstract:

lay groundwork for pluggable notification backends.
should be based around notification of events.

ideas for plugins:

mailgun -- after deploy
postmark
ping webservice with event information

notify when migrate start/end
notify when deploy start/end
notify when maintenance page is up
notify background processors stopped/started

collect metrics and benchmarks on tasks

on :deploy_start do
  deploy_timer = Time.now.to_f
end

on :deploy_complete do
  total = Time.now.to_f - deploy_timer
  puts "Deploy took #{ total }s to complete"
end

examples:

on :deploy_complete { Mailgun.notify }

on :migrate_start { IRC.chat("#{ application } Migration started.") }

on :maintenance_page_up { IRC.chat("#{ application } Maintenance started.") }

built-in messages capistrano variables:

migration_start_message
migration_complete_message
deploy_start_message
deploy_complete_message

deployment_notification_email_html
deployment_notification_email_text

notification email should be customizable:

custom CSS?
custom sections (log, target servers, breakdown of task times, etc)

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'capnotify'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capnotify

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
