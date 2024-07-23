sky.rb
======

## Overview

The official Ruby client for the [Sky database](http://skydb.io).
This client provides a simple wrapper around the Sky HTTP-based API.

## Installation

    $ gem install skydb


## API

### The Basics

To connect to your Sky database, simply create a client pointing to the appropriate host and port.
The client will default to `localhost:8585` unless otherwise specified.

```ruby
require "skydb"
client = SkyDB::Client.new(:host => 'localhost', :port => 8585)
```

### Table API

The table API allows you to retrieve table information, create tables and delete tables.

```ruby
require "skydb"
client = SkyDB::Client.new()

# Retrieve a list of all tables.
tables = client.get_tables()

# Retrieve data about a single table.
table = client.get_table()

# Create a new table named 'foo'.
table = client.create_table(:name => 'foo')

# Delete the 'foo' table.
client.delete_table(table)
```


### Property API

The property API allows you to retrieve property information, create properties, update properties and delete properties from a table.

There are five data types in Sky: `string`, `integer`, `float`, `boolean` and `factor`.
The first four are self-explanatory.
The `factor` data type acts like a `string` but internally it is represented as an integer with a lookup to the original string value.
This type should be used when you have categorical data such as gender, country or any property that has a limited number of possible values.

In addition to data types, Sky properties can also be transient or permanent.
A transient property means that the value of the property exists only for a single moment in time.
Typically this would be used for data related to a specific event such as the purchase amount of a checkout on a web site.
A permanent property means that the value of the property stays in effect until changed.
An example of this would be a user's gender or their household income.

```ruby
require "skydb"
client = SkyDB::Client.new()
table = client.get_table(:name => 'foo')

# Retrieve a list of all properties on the table.
properties = table.get_properties()

# Retrieve a single property from the table.
property = table.get_property()

# Create a new transient, integer property named 'purchase_amount'.
property = table.create_property(:name => 'purchase_amount', :transient => true, :data_type => 'integer')

# Update the 'purchase_amount' property to be named 'total_purchase_amount'.
# Note that only the name change be changed on a property -- not it's transiency or data type.
property.name = 'total_purchase_amount'
table.update_property(property)

# Delete the property.
table.delete_property(property)
```

### Event API

The event API allows you to add events to objects on a table.
In Sky, objects are simply a sum of their events so objects do not need to be created explicitly.
Simply add events using an object key (e.g. a user id, e-mail address, or some other uniquely identifying string).

When adding events to the database, Sky will automatically deduplicate permanent values.
For example, if you set an object's "gender" property to "male" at Jan 1st 2000 at 1pm and then set it to "male" again on Jan 1st 2000 at 2pm then Sky will remove the second gender value since it can be determined by the first event.

Sky will also merge a events if adding an event that already exists at the same time for a given object.
This is typically unlikely as Sky's time resolution is one microsecond.

```ruby
require "skydb"
client = SkyDB::Client.new()
table = client.get_table(:name => 'foo')
table.create_property(:name => "action", :transient => true, :data_type => "factor")
table.create_property(:name => "purchase_amount", :transient => true, :data_type => "float")
table.create_property(:name => "full_name", :data_type => "string")

# Retrieve a list of all events for an object.
events = table.get_events("susy")

# Retrieve the event that occurs at a given moment for an object.
event = table.get_event("susy", DateTime.iso8601('2000-01-01T00:00:00Z'))

# Add a new event for an object (and merge with an existing event).
table.add_event("susy", :timestamp => DateTime.iso8601('2000-01-01T00:00:00Z'), :data => {"action" => "checekout", "purchase_amount" => 100, "full_name" => "Susy Que"})

# Add a new event for an object (and replace an existing event).
table.add_event("susy", {:timestamp => DateTime.iso8601('2000-01-01T00:00:00Z'), :data => {"action" => "checekout", "purchase_amount" => 100, "full_name" => "Susy Que"}}, :method => :replace)

# Delete an event at the given moment.
table.delete_event("susy", :timestamp => DateTime.iso8601('2000-01-01T00:00:00Z'))
```

### Query API

Once your event data is in Sky, you can quickly iterate over it and query it for information.
There are two primitives in the Sky query system: conditions & selections.
Conditions allow you to execute nested conditions or selections if its expression evaluates to true.
Selections allow you to actually retrieve the data from the current event and group it by multiple dimensions.

For a full explanation of the Sky query system, please visit the [Sky web site](http://skydb.io).

```ruby
require "skydb"
client = SkyDB::Client.new()
table = client.get_table(:name => 'users')
table.create_property(:name => "action", :transient => true, :data_type => "factor")
table.create_property(:name => "purchase_amount", :transient => true, :data_type => "float")
table.create_property(:name => "gender", :data_type => "factor")
table.create_property(:name => "state", :data_type => "factor")

# Perform a simple count of all events in the table.
results = client.query([:type => 'selection', :fields => [{:name => 'myCount', :expression => 'count()'}]])

# Count the number of users that performed the actions 'view home page', 'sign up' and then 'checkout' within a session
# and group the results by gender and state.
results = client.query(
  :sessionIdleTime => 7200,
  :steps => [
    {:type => 'condition', :expression => 'action == "view home page"', :steps => [
      {:type => 'condition', :expression => 'action == "sign up"', :within => [1,1], :steps => [
        {:type => 'condition', :expression => 'checkout', :within => [1,1], :steps => [
          {:type => 'selection', :dimensions => ['gender', 'state'], :fields => [
            {:name => 'count', :expression => 'count()'},
            {:name => 'total_amount', :expression => 'sum(purchase_amount)'}
          ]},
        ]}
      ]}
    ]}
  ]
)
#=> {'gender' => {'m' => {'state' => {'CA' => {'count' => 10, 'total_amount' => 291.93}}}}
```

### Utility API

To check if the server is up and running, you can use the `ping` command:


```ruby
require "skydb"
client = SkyDB::Client.new()
is_running = client.ping()
```
