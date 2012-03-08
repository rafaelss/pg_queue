# PgQueue

Background jobs using PostgreSQL's LISTEN/NOTIFY

[![Build Status](https://secure.travis-ci.org/rafaelss/pg_queue.png)](http://travis-ci.org/rafaelss/pq_queue)

## Installation

Add this line to your application's Gemfile:

    gem 'pg_queue'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pg_queue

Now you need to create the table where jobs will be stored:

    $ rake environment pg_queue:create_table

Run `rake -T pg_queue` for more tasks

## Usage

### Rails

Create an initializer with the configuration

    PgQueue.connection = ActiveRecord::Base.connection.raw_connection
    PgQueue.logger = Rails.logger
    PgQueue.interval = 3 # the number of seconds you want the worker wait after process a job

Add this line in the Rakefile

    require "pg_queue/tasks"

And then start the worker running

    rake environment pg_queue:work

That's it! You're now able to enqueue your jobs. To do that, just call

    PgQueue.enqueue(MyQueueClass, "string", 1, false) # parameters will be JSON encoded

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
