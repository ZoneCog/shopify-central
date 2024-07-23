# Capistrano::EJSON

This gem makes it easy to use [ejson](https://github.com/Shopify/ejson) in applications that are deployed through Capistrano.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-ejson', '~> 1.0.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-ejson

## Usage

Require in `Capfile` to use the default task:

```ruby
require 'capistrano/ejson'
```

The task `ejson:decrypt` will run after `deploy:updated`.

By default the file `config/secrets.ejson` will be decrypted to `config/secrets.json`. You can change this behavior by specifying the following config variables:

```ruby
set :ejson_file, "config/secrets.ejson"
set :ejson_output_file, "config/secrets.json"
```

By default `capistrano-ejson` decrypts the secrets file from the machine that does the deploy and then uploads the resulting config to the servers. You can set `:ejson_deploy_mode` to `:remote` to perform the decryption remotely, which will run something like `ejson decrypt -o config/secrets.json config/secrets.ejson` on the remote hosts. If you need to use `sudo` or `bundle exec`, you should use the [SSHKit command map](https://github.com/capistrano/sshkit#the-command-map).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
