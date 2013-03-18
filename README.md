# Capnotify

Very much work-in-progress capistrano plugin for managing notifications. Features built-in
templates for emails and status updates of the deployment. Designed to be extensible by other
plugins to integration with other services (eg: mailgun, postmark, actionmailer, IRC, grove.io,
etc).

not quite working, yet.

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

## TODO/Notes

### abstract:

lay groundwork for pluggable notification backends.
should be based around notification of events.

### ideas for plugins:

 * mailgun -- after deploy
 * postmark
 * ping webservice with event information

### features

 * notify when migrate start/end
 * notify when deploy start/end
 * notify when maintenance page is up
 * notify background processors stopped/started

collect metrics and benchmarks on tasks

```ruby
    on :deploy_start do
      deploy_timer = Time.now.to_f
    end

    on :deploy_complete do
      total = Time.now.to_f - deploy_timer
      puts "Deploy took #{ total }s to complete"
    end
```

examples:

```ruby
on :deploy_complete { Mailgun.notify }

on :migrate_start { IRC.chat("#{ application } Migration started.") }

on :maintenance_page_up { IRC.chat("#{ application } Maintenance started.") }
```

### built-in messages capistrano variables:

 * migration_start_message
 * migration_complete_message
 * deploy_start_message
 * deploy_complete_message

 * deployment_notification_email_html
 * deployment_notification_email_text

notification email should be customizable:

 * custom CSS?
 * custom sections (log, target servers, breakdown of task times, etc)

email contains an array of Capnotify::EmailSection. each of those consists of:

 * header -- a subheading for this section
 * css_class -- the css class to use for styling
 * content -- either a string, array or hash. Or other, if the template supports it. officially, only these types are supported.
 * owner -- the plugin that created it.
 * name -- the name of the section (a symbol)

A Capnotify plugin may append (or insert, etc) an EmailSection at any moment.
At the time the template is built (when sending the email), the data is materialized
into the final form.

When adding sections, one specifies the owner (the name of the plugin that created it).
This enables the user to disable sections ad-hoc by plugin or by name.

capnotify.sections#blacklist_by_name
capnotify.sections#blacklist_by_plugin

sections should still be added, but will be skipped at time of template generation.
