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
extend for your notification needs. Until the 1.0 release, the interface can change
in drastic ways at any time. Be sure to restrict the version of the gem until a final release
is made.

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

Following are a few examples for hooking up into these callbacks.

### Quickstart

Capnotify can be used in your current deployment recipes and is easy to implement. The
following examples will get you up and running with these callbacks.

#### Short Messages

Capnotify has some built-in short messages right out of the box. If you'd like, for example,
to send a short message notification when deployment starts and completes, it can be
done like the following:

    on(:deploy_start) do
      SomeLib.send_message( capnotify_deploy_start_msg )
    end

    on(:deploy_complete) do
      SomeLib.send_message( capnotify_deploy_complete_msg )
    end

In the case of the above example, replace the `SomeLib#send_message` call with your library's
function.

A full list of available callbacks and built-in messages can be found below in the
*Hooks and Callbacks* and *Messages* sections.

#### Long Messages

Capnotify also has built-in long message HTML templates and are primarily designed for
building email messages, but don't necessarily need to be used for that.

For an example of how to send an email, see the following:

    on(:deploy_complete) do
      MyMailer.send_mail(
        :text_body => capnotify_deployment_notification_text,
        :html_body => capnotify_deployment_notification_html
      )
    end

The `capnotify_deployment_notification_text` and `capnotify_deployment_notification_html`
Capistrano variables are lazily evaluated, and when called, will generate the deployment
notification email bodies for text or html respectively.

See the section *Built-in Templates* below for more information about templates and how
to further customize them.

##### Components

Long messages can be further customized through the use of Components. Using the
`capnotify#components` function, you can add a `Capnotify::Component` which is a collection
of information inside the body of an email. Capnotify comes with 2 built-in components:
"Deployment Overview" and "Deployment Details" which contain the `ref`, `sha1`, deployer
username, Github URL, deployment time, and repository information about the deployment.

Some examples for extensions that could be added would be reports about deployment durations,
commit logs, information about previous deploys, or custom email messages.

A quick example of creating and appending a component to Capnotify is the following:

    capnotify.components << Capnotify::Component.new(:my_component) do |c|
      # this is the header that appears in the email:
      c.header = 'Deployment Overview'

      # initialize the content as a hash
      c.content = {}

      # build the collection of data
      c.content['Deployed by'] = capnotify.deployed_by
      c.content['Deployed at'] = Time.now
      c.content['Application'] = fetch(:application, '')
      c.content['Repository'] = fetch(:repository, '')
    end

This above example is taken straight from the `Overview` extension that's built into
Capnotify.

For more information on Components, see the **Components** section below.

#### More information

In addition, to take the next step and create reusable code, you can create an
Extension which can be packaged as a gem.

See **Extensions** for information on building extensions.

See **Hooks and Callbacks** for a list of available Capistrano callbacks.

See **Components** for information on creating components.

See **Built-in Templates** for information on customizing templates and replacing with
your own templates.

## Hooks and Callbacks

Capnotify provides hooks and callbacks for common, notifiable tasks in addition
to the standard Capistrano set.

### Default callbacks

Following are all of the built-in default callbacks. Each callback will have a brief
description of the purpose and the time at which it's called, suggested associated messages
(see **Messages** sections for more information about these) and an example of how to use it.

#### deploy_start

By default he `deploy_start` hook is called immediately before the
`deploy` Capistrano task.

Suggested message: `capnotify_deploy_start_msg`

##### Example:

    on(:deploy_start) do
      MyService.notify( capnotify_deploy_start_msg )
    end

#### deploy_complete

By default the `deploy_complete` hook is called immediately after the `deploy`
Capistrano task.

Suggested message: `capnotify_deploy_complete_msg`

##### Example:

    on(:deploy_complete) do
      MyService.notify( capnotify_deploy_complete_msg )
    end

#### migrate_start

By default, the `migrate_start` hook is called immediately before `deploy:migrate`. This hook
is designed to be used to notify DBAs of database changes or can be used to measure the
elapsed time a migration takes.

Suggested message: `capnotify_migrate_start_msg`

##### Example:

    on(:migrate_start) do
      MyService.notify( capnotify_migrate_start_msg )
    end

#### migrate_complete

By default, the `migrate_complete` hook is called immediately after `deploy:migrate` finishes.

Suggested message: `capnotify_migrate_complete_msg`

##### Example:

    on(:migrate_complete) do
      MyService.notify( capnotify_migrate_complete_msg )
    end

#### maintenance_page_up

By default, the `maintenance_page_up` hook is called immediately before `deploy:web:disable`.

Suggested message: `capnotify_maintenance_up_msg`

##### Example:

    on(:maintenance_page_up) do
      MyService.notify( capnotify_maintenance_up_msg )
    end

#### maintenance_page_down

By default, the `maintenance_page_down` hook is called immediately after `deploy:web:enable`.

Suggested message: `capnotify_maintenance_down_msg`

##### Example:

    on(:maintenance_page_down) do
      MyService.notify( capnotify_maintenance_down_msg )
    end

### Changing default callbacks

Because not every Capistrano configuration is the same and not every application's needs match,
Capnotify provides facilities to customize how the callbacks are called. In the event that your
recipe uses different task names than the above, you can manually call the hooks using the
`trigger` Capistrano function.

For example, if you use a `deploy:api` task for deployment, but still want to leverage the
`deploy_start` hook, you could do the following:

    before('deploy:api') { trigger :deploy_start }
    after('deploy:api')  { trigger :deploy_complete }

These hooks do not have to be triggered only inside `before`/`after` blocks; they can be
called from anywhere by using `trigger :deploy_start`.

### Disabling default callbacks

Setting the following Capistrano variables to `true` will disable the respective hook pairs:

 * `capnotify_disable_deploy_hooks`
 * `capnotify_disable_migrate_hooks`
 * `capnotify_disable_maintenance_hooks`

For example:

    set :capnotify_disable_deploy_hooks, true

Will disable triggering both `deploy_start` and `deploy_complete`.

Currently, this must be set **BEFORE** Capnotify is loaded to be effective.

## Built-in strings and functions

Capnotify has a collection of built-in strings for messages that can be embedded or overridden.
These are all built using the `capnotify.appname` function which contains the `application` and
optional `stage` values (eg: `MyApplication production`).

You can override these values by `set`'ing the value in your recipe or extension. For example:

    set :capnotify_migrate_start_msg, "Migration has just begun!"

### capnotify.appname

The `capnotify.appname` function calls the `capnotify_appname` Capistrano variable which,
by default, combines the `application` and the optional `stage` variables. To override this,
you can do something like the following example:

    set :capnotify_appname, "#{ application }/#{ branch }"

That will replace the behavior of the `capnotify.appname` calls.

### Messages

The following messages are built-in using Capistrano variables. They can be overridden using
the `set` command:

 * `capnotify_migrate_start_msg`
 * `capnotify_migrate_complete_msg`
 * `capnotify_deploy_start_msg`
 * `capnotify_deploy_complete_msg`
 * `capnotify_maintenance_up_msg`
 * `capnotify_maintenance_down_msg`

## Built-in Templates

TODO: full rundown of working with built-in templates

### Components

TODO: full rundown of working with components

 * name
 * header
 * custom css
 * content

also

 * appending / prepending components
 * deleting components
 * inserting components
 * getting component by name
 * lazy components

### Customizing Templates

TODO: write info for replacing built-in templates

 * replacing built-in templates

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

