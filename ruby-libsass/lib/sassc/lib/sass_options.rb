module SassC::Lib
  class SassOptions < FFI::Struct
    STYLES = %w(nested expanded compact compressed)
    SOURCE_COMMENTS = %w(none default map)

    # struct sass_options {
    #   int output_style;
    #   int source_comments; // really want a bool, but C doesn't have them
    #   char* include_paths;
    #   char* image_path;
    # };
    layout :output_style, :int,
      :source_comments, :int,
      :include_paths, :pointer,
      :image_path, :pointer

    def self.create(options = {})
      options = {
        :output_style => "nested",
        :source_comments => "none",
        :image_path => "images",
        :include_paths => ""
      }.merge(options)

      struct = SassOptions.new
      struct[:output_style] = STYLES.index(options[:output_style])
      struct[:source_comments] = SOURCE_COMMENTS.index(options[:source_comments])
      struct[:image_path] = FFI::MemoryPointer.from_string(options[:image_path])
      struct[:include_paths] = FFI::MemoryPointer.from_string(options[:include_paths])
      struct
    end
  end
end