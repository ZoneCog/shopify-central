# frozen_string_literal: true

module PedantMysql2
  class << self
    def capture_warnings
      warnings = backup_warnings
      setup_capture
      yield
      captured_warnings
    ensure
      restore_warnings(warnings)
    end

    def raise_warnings!
      self.on_warning = nil
    end

    def silence_warnings!
      self.on_warning = lambda{ |warning| }
    end

    def ignore(*matchers)
      self.whitelist.concat(matchers.flatten)
    end

    def warn(warning)
      return if ignored?(warning)

      if on_warning
        on_warning.call(warning)
      else
        raise warning
      end
    end

    def on_warning
      Thread.current[:__pedant_mysql2_on_warning] || @_on_warning
    end

    def on_warning=(new_proc)
      @_on_warning = new_proc
    end

    protected

    def whitelist
      @whitelist ||= []
    end

    def ignored?(warning)
      note_warning?(warning) || whitelist.any? { |matcher| warning.message.match?(matcher) }
    end

    def note_warning?(warning)
      warning.level == "Note"
    end

    def setup_capture
      Thread.current[:__pedant_mysql2_warnings] = []
      self.thread_on_warning = lambda { |warning| Thread.current[:__pedant_mysql2_warnings] << warning }
    end

    def captured_warnings
      Thread.current[:__pedant_mysql2_warnings]
    end

    def backup_warnings
      [captured_warnings, Thread.current[:__pedant_mysql2_on_warning]]
    end

    def restore_warnings(warnings)
      Thread.current[:__pedant_mysql2_warnings], self.thread_on_warning = *warnings
    end

    def thread_on_warning=(new_proc)
      Thread.current[:__pedant_mysql2_on_warning] = new_proc
    end
  end
end
