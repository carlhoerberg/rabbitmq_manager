# RabbitMQ Manager

A wrapper for RabbitMQs management HTTP API.

[More information on the API](http://hg.rabbitmq.com/rabbitmq-management/raw-file/rabbitmq_v3_2_4/priv/www/api/index.html)

## Installation

Add this line to your application's Gemfile:

    gem 'rabbitmq_manager'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rabbitmq_manager

## Usage

    rmq = RabbitMQManager.new 'http://guest:guest@localhost:15672'
    rmq.overview #=> cluster overview

    rmq.nodes #=> array of nodes
    rmq.node('node_name')

    rmq.vhosts #=> array of vhosts
    rmq.vhost_create 'vhost_name'
    rmq.vhost_delete 'vhost_name'

    rmq.users #=> array of users
    rmq.user_create 'username', 'password'
    rmq.user_delete 'username'
    rmq.user_set_permissions 'username', 'vhost', '.*', '.*', '.*'

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
