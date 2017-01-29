module Flutterby
  module Reading
    # Reloads the node from the filesystem, if it's a filesystem based
    # node.
    #
    def reload!
      logger.info "Reloading #{url.colorize(:blue)}"

      time = Benchmark.realtime do
        load!
        stage!
        emit(:reloaded)
      end

      logger.info "Reloaded #{url.colorize(:blue)} in #{sprintf("%.1fms", time * 1000).colorize(:light_white)}"
    end

    def data
      @data_proxy ||= Dotaccess[@data]
    end

    def source
      @source ||= (fs_path && File.file?(fs_path) ? File.read(fs_path) : nil)
    end


    private

    def load!
      clear!
      @timestamp = Time.now

      # Extract name, extension, and filters from given name
      parts    = @original_name.split(".")
      @name    = parts.shift
      @ext     = parts.shift
      @filters = parts.reverse

      load_from_filesystem! if @fs_path

      extract_data!
    end

    def load_from_filesystem!
      if @fs_path
        @timestamp = File.mtime(fs_path)

        if ::File.directory?(fs_path)
          Dir[::File.join(fs_path, "*")].each do |entry|
            name = ::File.basename(entry)
            Flutterby::Node.new(name, parent: self, fs_path: entry)
          end
        end
      end
    end

    def extract_data!
      @data ||= {}.with_indifferent_access

      # Extract prefix and slug
      if name =~ %r{\A([\d-]+)-(.+)\Z}
        @prefix = $1
        @slug = $2
      else
        @slug = name
      end

      # Change this node's name to the slug. This may be made optional
      # in the future.
      @name = @slug

      # Extract date from prefix if possible
      if prefix =~ %r{\A(\d\d\d\d\-\d\d?\-\d\d?)\Z}
        @data['date'] = Date.parse($1)
      end

      # Read remaining data from frontmatter. Data in frontmatter
      # will always have precedence!
      extract_frontmatter!

      # Do some extra processing depending on extension. This essentially
      # means that your .json etc. files will be rendered at least once at
      # bootup.
      meth = "read_#{ext}!"
      send(meth) if respond_to?(meth, true)
    end

    def extract_frontmatter!
      if source
        # YAML Front Matter
        if source.sub!(/\A\-\-\-\n(.+?)\n\-\-\-\n/m, "")
          @data.merge! YAML.load($1)
        end

        # TOML Front Matter
        if source.sub!(/\A\+\+\+\n(.+?)\n\+\+\+\n/m, "")
          @data.merge! TOML.parse($1)
        end
      end
    rescue ArgumentError => e
    end

    def read_json!
      @data.merge!(JSON.parse(render))
    end

    def read_yaml!
      @data.merge!(YAML.load(render))
    end

    def read_yml!
      read_yaml!
    end

    def read_toml!
      @data.merge!(TOML.parse(render))
    end
  end
end
