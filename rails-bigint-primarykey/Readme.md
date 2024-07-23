## rails-bigint-primarykey [![Build Status](https://secure.travis-ci.org/Shopify/rails-bigint-primarykey.png?branch=master)](https://travis-ci.org/Shopify/rails-bigint-primarykey)

### Overview

rails-bigint-primarykey aims to be a simple, transparent way to use 64bit primary keys
in MySQL and PostgreSQL.

This gem was initially a fork of the [rails-bigint-pk](https://github.com/caboteria/rails-bigint-pk) gem but it was
significantly rewritten to support Rails 5.

### Installation & Usage

Add the following to your `Gemfile`:

```
gem 'rails-bigint-primarykey'
```

### Gotchas

When adding foreign key columns, be sure to use `references` and not
`add_column`.

```ruby
change_table :my_table do |t|
  t.references :other_table
end

# Doing this will not use 64bit ints
add_column :my_table, :other_table_id, :int
```

When upgrading to Rails 5.1 you still need this gem if your were using it before and your migrations still use the
version 5.0 or previous.
