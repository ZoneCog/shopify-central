module Viking
  class File

    def self.absolute_path(file_name, dir_string=Viking.client.get_working_directory)
      dir_string = dir_string.to_s.sub(/[^\/]*:\/*\//, '/')
      ::File.absolute_path(file_name, dir_string)
    end

    def self.basename(file_name, suffix = nil)
      base = file_name.split("/").last
      suffix.nil? ? base : base.sub(suffix, '')
    end

    def self.chmod(mode_int, *file_names)
      permission = FsPermission.new(mode_int)
      file_names.each do |file_name|
        Viking.client.set_permission(Path.new(file_name), permission)
      end
      file_names.size
    end

    def self.chown(owner_name, group_name, *file_names)
      file_names.each do |file_name|
        Viking.client.set_owner(Path.new(file_name), owner_name, group_name)
      end
      file_names.size
    end

    def self.delete(*file_names)
      file_names.each do |file_name|
        path = Path.new(file_name)
        if file?(file_name)
          Viking.client.delete(Path.new(file_name), false)
        else
          raise IOError, "File::delete can only delete files. Attempted to delete directory #{file_name}."
        end
      end
      file_names.size
    end

    def self.directory?(file_name)
      Viking.client.is_directory(Path.new(file_name))
    end

    def self.exist?(file_name)
      exists?(file_name)
    end

    def self.exists?(file_name)
      Viking.client.exists(Path.new(file_name))
    end

    def self.file?(file_name)
      Viking.client.is_file(Path.new(file_name))
    end

    def self.ftype(file_name)
      directory?(file_name) ? 'directory' : 'file'
    end

    def self.move(old_name, new_name)
      rename(old_name, new_name)
    end

    def self.open(file_name, &block)
      file = Viking::File.new(file_name)
      if block
        value = yield file
        file.close unless file.closed?
        value
      else
        file
      end
    end

    def self.rename(old_name, new_name)
      Viking.client.rename(Path.new(old_name), Path.new(new_name))
    end

    def self.size(file_name)
      Viking.client.get_file_status(Path.new(file_name)).get_len
    end

    def self.size?(file_name)
      exists?(file_name) ? size(file_name) : nil
    end

    def self.split(file_name)
      name = basename(file_name)
      path = file_name.sub(/\/#{name}$/,'')
      [path, name]
    end

    def initialize(file_name)
      @path     = file_name
      @reading  = false
      @writing = false
      @closed   = false
    end

    def path
      @path
    end

    def size
      Viking.client.get_file_status(Path.new(path)).get_len
    end

    def close
      unless closed?
        reader.close  if @reading
        writer.close if @writing

        @reading  = false
        @writing = false

        @closed = true
      end
    end

    def closed?
      @closed
    end

    def each_line(sep="\n", limit=nil)
      while((line = gets(sep, limit)) != nil) do
        yield line
      end
      close
    end

    def each_char
      while(char = getc) do
        yield char
      end
      close
    end

    def eof
      eof?
    end

    def eof?
      current_byte.nil?
    end

    def getc
      byte = current_byte
      next_byte
      byte
    end

    def gets(sep=nil, limit=nil)
      sep_bytes = sep.bytes.to_a if sep
      bytes     = []
      while(b = getc) do
        bytes << b
        break if sep   && bytes.last(sep_bytes.size) == sep_bytes
        break if limit && bytes.size == limit
      end
      bytes.empty? ? nil : bytes.pack("C*")
    end

    def putc(obj)
      if obj.is_a? Numeric
        writer.java_send :write, [Java::int], obj
      else
        byte = obj.to_s.bytes.first
        writer.write(byte)
      end
    end

    def puts(*objs)
      separator = "\n"
      string    = objs.reduce("") do |acc, obj|
        if obj.end_with?(separator)
          acc << obj
        else
          acc << obj
          acc << separator
        end
      end
      write(string)
    end

    def read(limit=nil)
      gets(nil, limit)
    end

    def write(string)
      writer.write(string.to_java_bytes)
    end

    private

    def parse_byte(b)
      b == -1 ? nil : b
    end

    def next_byte
      b  = reader.read
      @b = parse_byte(b)
    end

    def current_byte
      next_byte unless @reading
      @b
    end

    def reader
      @reader ||= begin
        @reading = true
        Viking.client.open(Path.new(path))
      end
    end

    def writer
      @writer ||= begin
        @writing = true
        Viking.client.create(Path.new(path), true, Viking.buffer_size)
      end
    end
  end
end
