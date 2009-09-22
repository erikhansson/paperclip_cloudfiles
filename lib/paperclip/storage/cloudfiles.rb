
module Paperclip
  module Storage
    
    # Alternative Storage for Paperclip, using Rackspace's CloudFiles storage
    # service. All files will be saved to a specified CDN-enabled container.
    module Cloudfiles
      
      def self.extended base
        begin
          require 'cloudfiles'
        rescue LoadError => e
          e.message << " (You may need to install the rackspace-cloudfiles gem)"
          raise e
        end

        base.instance_eval do
          @cf_credentials    = @options[:cloudfiles][:credentials]
          @cf_container_name = @options[:cloudfiles][:container]
          @cf_base_url       = @options[:cloudfiles][:base_url]
        end
        
        Paperclip.interpolates(:cf_base_url) do |attachment, style|
          "#{cf_base_url}"
        end
      end
      
      def cf_connection
        # TODO: Ensure that this works acceptably. A new CloudFiles::Connection and
        # container instance will be created for each attachment when the corresponding
        # methods are called. Those could probably be shared for all instances of the
        # same attachment for the process.
        
        @cf_connection ||= CloudFiles::Connection.new(@cf_credentials[:username], @cf_credentials[:api_key])
      end
      
      def cf_container
        @cf_container ||= cf_connection.container(cf_container_name)
      end
      
      def cf_container_name
        @cf_container_name
      end

      def cf_base_url
        @cf_base_url ||= cf_container.cdn_url
      end

      # Checks wether this attachment exists in the given style.
      def exists?(style = default_style)
        if original_filename
          cf_container.object_exists?(path(style))
        else
          false
        end
      end

      # Returns representation of the data of the file assigned to the given
      # style, in the format most representative of the current storage.
      def to_file style = default_style
        return @queued_for_write[style] if @queued_for_write[style]
        file = Tempfile.new(path(style))
        file.write(cf_container.object(path(style)).value)
        file.rewind
        return file
      end

      def flush_writes #:nodoc:
        @queued_for_write.each do |style, file|
          begin
            log("saving to cloudfiles #{path(style)}")
            obj = cf_container.create_object(path(style))
            obj.write(file)
          rescue StandardError => e
            raise
          end
        end
        @queued_for_write = {}
      end

      def flush_deletes #:nodoc:
        @queued_for_delete.each do |path|
          begin
            log("deleting from cloudfiles #{path}")
            cf_container.delete(path)
          end
        end
        @queued_for_delete = []
      end

    end
  end
end
