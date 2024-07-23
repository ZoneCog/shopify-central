require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

namespace :db do
  namespace :mysql do
    desc 'Build the MySQL test database'
    task :build do
      `mysql --user=root -e "create DATABASE bigint_test DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_unicode_ci"`
    end

    desc 'Drop the MySQL test database'
    task :drop do
      `mysqladmin --user=root -f drop bigint_test`
    end

    desc 'Rebuild the MySQL test database'
    task rebuild: [:drop, :build]
  end

  namespace :postgresql do
    desc 'Build the PostgreSQL test database'
    task :build do
      `createdb -E UTF8 -T template0 bigint_test`
    end

    desc 'Drop the PostgreSQL test databases'
    task :drop do
      `dropdb bigint_test`
    end

    desc 'Rebuild the PostgreSQL test databases'
    task rebuild: [:drop, :build]
  end
end

task default: :test
