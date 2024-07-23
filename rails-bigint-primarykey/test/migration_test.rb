require 'minitest/autorun'
require 'bigint_primarykey'

BigintPrimarykey.enable!(ENV['ADAPTER'] || "mysql2")

class MigrationTest < Minitest::Test
  attr_reader :connection

  def setup
    super
    ActiveRecord::Base.establish_connection(adapter: ENV['ADAPTER'] || "mysql2", database: "bigint_test")
    @connection = ActiveRecord::Base.connection
    @verbose_was = ActiveRecord::Migration.verbose
    ActiveRecord::Migration.verbose = false
  end

  def teardown
    super
    begin
      ActiveRecord::Base.connection.drop_table("foo")
    rescue
      nil
    end
    ActiveRecord::Migration.verbose = @verbose_was
    begin
      ActiveRecord::SchemaMigration.delete_all
    rescue
      nil
    end
  end

  def test_creating_a_table_use_bigint_as_primary_key
    connection.create_table('foo')
    columns = connection.columns(:foo)
    assert_equal ['id'], columns.map(&:name)
    assert_equal [:integer], columns.map(&:type)
    if ENV['ADAPTER'] == 'postgresql'
      assert_equal ['bigint'], columns.map(&:sql_type)
      assert_equal ["nextval('foo_id_seq'::regclass)"], columns.map(&:default_function)
    else
      assert_equal ['bigint(20)'], columns.map(&:sql_type)
      assert_equal ['auto_increment'], columns.map(&:extra)
    end
    assert_equal [8], columns.map(&:limit)
  end

  def test_creating_a_reference_column_uses_bigint
    connection.create_table('foo') do |td|
      td.references :post
    end
    columns = connection.columns(:foo)
    assert_equal %w(id post_id), columns.map(&:name)
    assert_equal [:integer, :integer], columns.map(&:type)
    if ENV['ADAPTER'] == 'postgresql'
      assert_equal %w(bigint bigint), columns.map(&:sql_type)
    else
      assert_equal ['bigint(20)', 'bigint(20)'], columns.map(&:sql_type)
    end
    assert_equal [8, 8], columns.map(&:limit)
  end

  def test_creating_a_table_use_bigint_as_primary_key_works_in_a_rails_4_2_migration
    skip if rails_42?
    migration = Class.new(ActiveRecord::Migration[4.2]) do
      def version
        101
      end

      def migrate(*)
        create_table :foo
      end
    end.new

    ActiveRecord::Migrator.new(:up, [migration]).migrate

    columns = connection.columns(:foo)
    assert_equal ['id'], columns.map(&:name)
    assert_equal [:integer], columns.map(&:type)
    if ENV['ADAPTER'] == 'postgresql'
      assert_equal ['bigint'], columns.map(&:sql_type)
      assert_equal ["nextval('foo_id_seq'::regclass)"], columns.map(&:default_function)
    else
      assert_equal ['bigint(20)'], columns.map(&:sql_type)
      assert_equal ['auto_increment'], columns.map(&:extra)
    end
    assert_equal [8], columns.map(&:limit)
  end

  def test_creating_a_reference_column_uses_bigint_works_in_a_rails_4_2_migration
    skip if rails_42?
    migration = Class.new(ActiveRecord::Migration[4.2]) do
      def version
        101
      end

      def migrate(*)
        create_table :foo do |td|
          td.references :post
        end
      end
    end.new

    ActiveRecord::Migrator.new(:up, [migration]).migrate

    columns = connection.columns(:foo)
    assert_equal %w(id post_id), columns.map(&:name)
    assert_equal [:integer, :integer], columns.map(&:type)
    if ENV['ADAPTER'] == 'postgresql'
      assert_equal %w(bigint bigint), columns.map(&:sql_type)
    else
      assert_equal ['bigint(20)', 'bigint(20)'], columns.map(&:sql_type)
    end
    assert_equal [8, 8], columns.map(&:limit)
  end

  def test_creating_a_table_use_bigint_as_primary_key_works_in_a_rails_5_0_migration
    skip if rails_42?
    migration = Class.new(ActiveRecord::Migration[5.0]) do
      def version
        101
      end

      def migrate(*)
        create_table :foo
      end
    end.new

    ActiveRecord::Migrator.new(:up, [migration]).migrate

    columns = connection.columns(:foo)
    assert_equal ['id'], columns.map(&:name)
    assert_equal [:integer], columns.map(&:type)
    if ENV['ADAPTER'] == 'postgresql'
      assert_equal ['bigint'], columns.map(&:sql_type)
      assert_equal ["nextval('foo_id_seq'::regclass)"], columns.map(&:default_function)
    else
      assert_equal ['bigint(20)'], columns.map(&:sql_type)
      assert_equal ['auto_increment'], columns.map(&:extra)
    end
    assert_equal [8], columns.map(&:limit)
  end

  def test_creating_a_reference_column_uses_bigint_works_in_a_rails_5_0_migration
    skip if rails_42?
    migration = Class.new(ActiveRecord::Migration[5.0]) do
      def version
        101
      end

      def migrate(*)
        create_table :foo do |td|
          td.references :post
        end
      end
    end.new

    ActiveRecord::Migrator.new(:up, [migration]).migrate

    columns = connection.columns(:foo)
    assert_equal %w(id post_id), columns.map(&:name)
    assert_equal [:integer, :integer], columns.map(&:type)
    if ENV['ADAPTER'] == 'postgresql'
      assert_equal %w(bigint bigint), columns.map(&:sql_type)
    else
      assert_equal ['bigint(20)', 'bigint(20)'], columns.map(&:sql_type)
    end
    assert_equal [8, 8], columns.map(&:limit)
  end

  def test_creating_a_table_use_bigint_as_primary_key_works_in_a_rails_5_1_migration
    skip if rails_42? || rails_50?
    migration = Class.new(ActiveRecord::Migration[5.1]) do
      def version
        101
      end

      def migrate(*)
        create_table :foo
      end
    end.new

    ActiveRecord::Migrator.new(:up, [migration]).migrate

    columns = connection.columns(:foo)
    assert_equal ['id'], columns.map(&:name)
    assert_equal [:integer], columns.map(&:type)
    if ENV['ADAPTER'] == 'postgresql'
      assert_equal ['bigint'], columns.map(&:sql_type)
      assert_equal ["nextval('foo_id_seq'::regclass)"], columns.map(&:default_function)
    else
      assert_equal ['bigint(20)'], columns.map(&:sql_type)
      assert_equal ['auto_increment'], columns.map(&:extra)
    end
    assert_equal [8], columns.map(&:limit)
  end

  def test_creating_a_reference_column_uses_bigint_works_in_a_rails_5_1_migration
    skip if rails_42? || rails_50?
    migration = Class.new(ActiveRecord::Migration[5.1]) do
      def version
        101
      end

      def migrate(*)
        create_table :foo do |td|
          td.references :post
        end
      end
    end.new

    ActiveRecord::Migrator.new(:up, [migration]).migrate

    columns = connection.columns(:foo)
    assert_equal %w(id post_id), columns.map(&:name)
    assert_equal [:integer, :integer], columns.map(&:type)
    if ENV['ADAPTER'] == 'postgresql'
      assert_equal %w(bigint bigint), columns.map(&:sql_type)
    else
      assert_equal ['bigint(20)', 'bigint(20)'], columns.map(&:sql_type)
    end
    assert_equal [8, 8], columns.map(&:limit)
  end

  private

  def rails_42?
    ActiveRecord.gem_version < Gem::Version.new("5")
  end

  def rails_50?
    ActiveRecord.gem_version < Gem::Version.new("5.1")
  end
end
