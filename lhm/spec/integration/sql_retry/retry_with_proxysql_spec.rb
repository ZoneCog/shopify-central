require 'minitest/autorun'
require 'lhm'
require 'toxiproxy'

require 'integration/sql_retry/lock_wait_timeout_test_helper'
require 'integration/sql_retry/db_connection_helper'
require 'integration/sql_retry/proxysql_helper'
require 'integration/toxiproxy_helper'

describe Lhm::SqlRetry, "ProxiSQL tests for LHM retry" do
  include ToxiproxyHelper

  before(:each) do
    @old_logger = Lhm.logger
    @logger = StringIO.new
    Lhm.logger = Logger.new(@logger)

    @connection = DBConnectionHelper::new_mysql_connection(:proxysql, true, true)

    @lhm_retry = Lhm::SqlRetry.new(@connection, retry_options: {},
                                   reconnect_with_consistent_host: true)
  end

  after(:each) do
    # Restore default logger
    Lhm.logger = @old_logger
  end

  it "Will abort if service is down" do

    e = assert_raises Lhm::Error do
      #Service down
      Toxiproxy[:mysql_proxysql].down do
        @lhm_retry.with_retries do |retriable_connection|
          retriable_connection.execute("INSERT INTO #{DBConnectionHelper.test_table_name} (id) VALUES (2000)")
        end
      end
    end
    assert_equal Lhm::Error, e.class
    assert_match(/LHM tried the reconnection procedure but failed. Aborting/, e.message)
  end

  it "Will retry until connection is achieved" do

    #Creating a network blip
    ToxiproxyHelper.with_kill_and_restart(:mysql_proxysql, 2.seconds) do
      @lhm_retry.with_retries do |retriable_connection|
        retriable_connection.execute("INSERT INTO #{DBConnectionHelper.test_table_name} (id) VALUES (2000)")
      end
    end

    assert_equal 2000, @connection.select_one("SELECT * FROM #{DBConnectionHelper.test_table_name} WHERE id=2000")["id"]

    logs = @logger.string.split("\n")

    assert logs.first.include?("Lost connection to MySQL, will retry to connect to same host")
    assert logs.last.include?("LHM successfully reconnected to initial host")
  end

  it "Will abort if new writer is not same host" do
    # The hostname will be constant before the blip
    Lhm::SqlRetry.any_instance.stubs(:hostname).returns("mysql-1").then.returns("mysql-2")
    Lhm::SqlRetry.any_instance.stubs(:server_id).returns(1).then.returns(2)

    # Need new instance for stub to take into effect
    lhm_retry = Lhm::SqlRetry.new(@connection, retry_options: {},
                                  reconnect_with_consistent_host: true)

    e = assert_raises Lhm::Error do
      #Creating a network blip
      ToxiproxyHelper.with_kill_and_restart(:mysql_proxysql, 2.seconds) do
        lhm_retry.with_retries do |retriable_connection|
          retriable_connection.execute("INSERT INTO #{DBConnectionHelper.test_table_name} (id) VALUES (2000)")
        end
      end
    end

    assert_equal e.class, Lhm::Error
    assert_match(/LHM tried the reconnection procedure but failed. Aborting/, e.message)

    logs = @logger.string.split("\n")

    assert logs.first.include?("Lost connection to MySQL, will retry to connect to same host")
    assert logs.last.include?("Reconnected to wrong host. Started migration on: mysql-1 (server_id: 1), but reconnected to: mysql-2 (server_id: 2).")
  end

  it "Will abort if failover happens (mimicked with proxySQL)" do
    e = assert_raises Lhm::Error do
      #Creates a failover by switching the target hostgroup for the #hostname
      ProxySQLHelper.with_lhm_hostgroup_flip do
        #Creating a network blip
        ToxiproxyHelper.with_kill_and_restart(:mysql_proxysql, 2.seconds) do
          @lhm_retry.with_retries do |retriable_connection|
            retriable_connection.execute("INSERT INTO #{DBConnectionHelper.test_table_name} (id) VALUES (2000)")
          end
        end
      end
    end

    assert_equal e.class, Lhm::Error
    assert_match(/LHM tried the reconnection procedure but failed. Aborting/, e.message)

    logs = @logger.string.split("\n")

    assert logs.first.include?("Lost connection to MySQL, will retry to connect to same host")
    assert logs.last.include?("Reconnected to wrong host. Started migration on: mysql-1 (server_id: 1), but reconnected to: mysql-2 (server_id: 2).")
  end
end
