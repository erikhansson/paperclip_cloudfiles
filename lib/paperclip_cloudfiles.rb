require 'paperclip/storage/cloudfiles'

module Paperclip
  class WithDefault
    cattr_accessor :options
    
    # Default options for CloudFiles.
    def self.cloudfiles_options
      @cloudfiles_options ||= {
        :url           => ":cf_base_url:path",
        :path          => "/attachments/:class/:attachment/:id/:style/:filename",
        :storage       => :cloudfiles
      }
    end
    
    # Sets Paperclip::WithDefault.options to the given option
    # hash merged with Paperclip::WithDefault.cloudfiles_options
    def self.use_cloudfiles_options(options)
      options = cloudfiles_options.merge(options)
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

# Make has_attached_file_with_defaults available in ActiveRecord::Base
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.extend Paperclip::WithDefault::ClassMethods
end

# Provide default options, primarily for development and test environments.
if Rails.env == 'development' || Rails.env == 'production'
  Paperclip::WithDefault.options ||= {}
elsif Rails.env == 'test'
  Paperclip::WithDefault.options ||= {
    :url => '/system/paperclip_test/:attachment/:id/:style/:filename'
  }
end
