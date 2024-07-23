# Viking

A familiar jRuby hdfs wrapper.

[![Build Status](https://travis-ci.org/tyro89/Viking.png?branch=master)](https://travis-ci.org/tyro89/Viking)

## Goal

The goal is to provide ways that are similar to the common ruby file system
api's for interacting with hdfs. All hdfs functionallity is powered by the java
hdfs classes.

## Status

### Available

 - `File`
 - `Dir`
 - `FileUtils`

### Not available yet but on the todo

 - `File#fnmatch`
 - `File#fnmatch?`
 - `Dir#glob`
 - `FileUtils#copy`

## Example usage

    # Set up hdfs config
    Viking.configure({
      path: "hdfs://hadoop-production" # if using HA hadoop
    })

    Viking.configure({
      path: "hdfs://namenode.yourcompany.com:8020" # if using a single namenode
    })

    # If "/some/data" exists and it is a file then print its content. If it is
    # a directory then rename it. If it does not exist then we create it.
    path = "/some/data"
    if Viking::File.exists? path
      if Viking::File.file? path
        Viking::File.open(path) do |file|
          puts "Reading data from #{f.path}:"
          puts f.read
        end
      else
        Viking::File.rename(path, "/some/dir")
      end
    else
      Viking::Dir.mkdir(path)
    end

Releasing a new version
-----------------------

1. Update the version in `version.rb`
2. Commit this to master
3. Tag the commit with `git tag <version>` from (1) and run `git push --tags`
4. Go to [Shipit](https://shipit.shopify.io/shopify/Viking/production) and click deploy on the respective commit

Installation
---

```ruby
source 'https://packages.shopify.io/shopify/gems' do
  gem 'hdfs-viking'
end
```
