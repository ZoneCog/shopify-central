# FrozenRecord

[![Build Status](https://secure.travis-ci.org/byroot/frozen_record.png)](http://travis-ci.org/byroot/frozen_record)
[![Code Climate](https://codeclimate.com/github/byroot/frozen_record.png)](https://codeclimate.com/github/byroot/frozen_record)
[![Coverage Status](https://coveralls.io/repos/byroot/frozen_record/badge.png)](https://coveralls.io/r/byroot/frozen_record)
[![Gem Version](https://badge.fury.io/rb/frozen_record.png)](http://badge.fury.io/rb/frozen_record)

ActiveRecord-like interface for **read only** access to YAML static data.

## Installation

Add this line to your application's Gemfile:

    gem 'frozen_record'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install frozen_record

## Models definition

Just like with ActiveRecord, your models need to inherits from `FrozenRecord::Base`:

```ruby
class Country < FrozenRecord::Base
end
```

But you also have to specify in which directory your data files are located.
You can either do it globaly

```ruby
FrozenRecord::Base.base_path = '/path/to/some/directory'
```

Or per model:
```ruby
class Country < FrozenRecord::Base
  self.base_path = '/path/to/some/directory'
end
```

## Query interface

FrozenRecord aim to replicate only modern ActiveRecord querying interface, and only the non "string typed" ones.

e.g
```ruby
# Supported query interfaces
Country.
  where(region: 'Europe').
  where.not(language: 'English').
  order(id: :desc).
  limit(10).
  offset(2).
  pluck(:name)

# Non supported query interfaces
Country.
  where('region = "Europe" AND language != "English"').
  order('id DESC')
```

### Scopes

While the `scope :symbol, lambda` syntax is not supported, the class methods way is:

```ruby
class Country
  def self.republics
    where(king: nil)
  end

  def self.part_of_nato
    where(nato: true)
  end
end

Country.republics.part_of_nato.order(id: :desc)
```

### Supported query methods

  - where
  - where.not
  - order
  - limit
  - offset

### Supported finder methods

  - find
  - first
  - last
  - to_a
  - exists?

### Supported calculation methods

  - count
  - pluck
  - ids
  - minimum
  - maximum
  - sum
  - average


## Configuration

### Reloading

By default the YAML files are parsed once and then cached in memory. But in development you might want changes to be reflected without having to restart your application.

For such cases you can set `auto_reloading` to `true` either globally or on a model basis:

```ruby
FrozenRecord::Base.auto_reloading = true # Activate reloading for all models
Country.auto_reloading # Activate reloading for `Country` only
```

## Contributors

FrozenRecord is a from scratch reimplementation of a [Shopify](https://github.com/Shopify) project from 2007 named `YamlRecord`.
So thanks to:

  - John Duff - [@jduff](https://github.com/jduff)
  - Dennis O'Connor - [@dennisoconnor](https://github.com/dennisoconnor)
  - Christopher Saunders - [@csaunders](https://github.com/csaunders)
  - Jonathan Rudenberg - [@titanous](https://github.com/titanous)
  - Jesse Storimer - [@jstorimer](https://github.com/jstorimer)
  - Cody Fauser - [@codyfauser](https://github.com/codyfauser)
  - Tobias Lütke - [@tobi](https://github.com/tobi)
