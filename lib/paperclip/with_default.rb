module Paperclip
  class WithDefault
    cattr_accessor :options
    
    # Default options for CloudFiles.
    def self.cloudfiles_options
      @cloudfiles_options ||= {
        :url           => ":container_url/attachments/:class/:attachment/:id/:style/:filename",
        :path          => "attachments/:class/:attachment/:id/:style/:filename",
        :storage       => :cloudfiles
      }
    end
    
    # Sets Paperclip::WithDefault.options to the given option
    # hash merged with Paperclip::WithDefault.cloudfiles_options
    def self.use_cloudfiles_options(options)
      Paperclip::WithDefault.options = cloudfiles_options.merge(options)
    end
    
    
    module ClassMethods
      
      # Simply calls has_attached_file with the default values found in
      # Paperclip::WitDefault.options merged into options.
      def has_attached_file_with_defaults(name, options = {})
        has_attached_file name, Paperclip::WithDefault.options.merge(options)
      end
      
    end
  end
end
