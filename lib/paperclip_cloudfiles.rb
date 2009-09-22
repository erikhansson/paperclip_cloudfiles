require 'paperclip/storage/cloudfiles'
require 'paperclip/with_default'


# Make has_attached_file_with_defaults available in ActiveRecord::Base
if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.extend Paperclip::WithDefault::ClassMethods
end

# Provide default options, primarily for development and test environments.
if Rails.env == 'development' || Rails.env == 'production'
  Paperclip::WithDefault.options ||= {}
elsif Rails.env == 'test'
  Paperclip::WithDefault.options ||= {
    :url => '/system_test/:attachment/:id/:style/:filename'
  }
end
