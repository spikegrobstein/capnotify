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

    gem "capnotify", "~> 0.2"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capnotify

Then, in your `Capfile`, add the following line:

    require 'capnotify'

## Usage

The current build of Capnotify is designed to be extended and doesn't provide much in the way
of notifications out of the box. It does, however, lay out a framework with with default messages
and provides a series of Capistrano callbacks
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
**Hooks and Callbacks** and **Messages** sections.

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

See the section **Built-in Templates** below for more information about templates and how
to further customize them.

#### More information

The [Capnotify wiki](https://github.com/spikegrobstein/capnotify/wiki) is loaded with
documentation on all of the ins and outs of Capnotify.

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

