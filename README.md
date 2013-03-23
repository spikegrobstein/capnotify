# Capnotify  [![Build Status](https://travis-ci.org/spikegrobstein/capnotify.png)](https://travis-ci.org/spikegrobstein/capnotify)

             __________________
        - --|\   Deployment   /|    _____                    __  _ ___
       - ---| \   Complete   / |   / ___/__ ____  ___  ___  / /_(_) _/_ __
      - ----| /\____________/\ |  / /__/ _ `/ _ \/ _ \/ _ \/ __/ / _/ // /
     - -----|/ - Capistrano - \|  \___/\_,_/ .__/_//_/\___/\__/_/_/ \_, /
    - ------|__________________|          /_/                      /___/

Standardized and robust notifications sent from your Capistrano recipes.

When dealing with large-scale deployment notifications, it's important to have
consistent language across notification media. Capnotify offers an extensible and standardized
framework for which to send notifications at different stages of your deployment,
mechanisms to extend and customize those messages as well as a collection of
built-in, predefined messages and templates.

Although currently a work in progress, Capnotify provides a solid framework to
extend for your notification needs.

## Installation

Add this line to your application's Gemfile:

    gem 'capnotify'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capnotify

Then, in your `Capfile`, add the following line:

    require 'capnotify'

## Usage

The current build of Capnotify is designed to be extended and doesn't provide much in the way
of notifications out of the box. It does, however, provide a series of Capistrano callbacks
that you can hook into and leverage your existing notification system, be it IRC, Email, 
Hipchat, or Grove.io.

See *Hooks and Callbacks* for a list of available Capistrano callbacks.

See *Extensions* for information on building extensions.

## Hooks and Callbacks

Capnotify provides hooks and callbacks for common, notifiable tasks in addition
to the standard Capistrano set.

### Default callbacks

Following are all of the built-in default callbacks. Each callback will have a brief
description of the purpose and the time at which it's called, suggested associated messages
(see *Messages* sections for more information about these) and an example of how to use it.

#### `deploy_start`

By default he `deploy_start` callback is called automatically immediately before the
`deploy` Capistrano task.

Suggested message: `capnotify_deploy_start_msg`

##### Example:

    ```ruby
    on(:deploy_start) do
      MyService.notify( capnotify_deploy_start_msg )
    end
    ```

#### `deploy_complete`

#### `migrate_start`

#### `migrate_complete`

#### `maintenance_page_up`

#### `maintenance_page_down`

### Changing default callbacks

## Built-in strings and functions

### Messages

## Built-in Templates

### Components

### Customizing templates

## Extensions

Need to write this.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author

Capnotify is &copy; 2013, written and maintained by Spike Grobstein and distributed under
the MIT license (included in this repository).

Homepage: https://github.com/spikegrobstein/capnotify  
Spike Grobstein: me@spike.cx / http://spike.grobste.in

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
 * custom components (log, target servers, breakdown of task times, etc)

email contains an array of Capnotify::Component. each of those consists of:

 * header -- a subheading for this component
 * css_class -- the css class to use for styling
 * content -- either a string, array or hash. Or other, if the template supports it. officially, only these types are supported.
 * owner -- the plugin that created it.
 * name -- the name of the component (a symbol)

A Capnotify extension may append (or insert, etc) a Component at any moment.

When the template(s) are built, components are iterated over (in order) and
materialized into the template.

```ruby
capnotify.components #=> an array of loaded components
capnotify.remove_component( name ) #=> remove the named component and return it
capnotify.component( name ) #=> return the named component
```

### Extensions

```ruby
class Overview < Capnotify::Extension

  # called when initializing
  def setup

  end
end
```

