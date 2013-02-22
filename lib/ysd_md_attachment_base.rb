require 'ysd-plugins' unless defined?Plugins::ModelAspect
require 'ysd_md_file_set_attachment' unless defined?Model::FileSetAttachment
require 'ysd_md_configuration' unless defined?SystemConfiguration::Variable

module Model
 
  #
  # Attachment management
  #
  # ====
  #
  # Usage:
  #
  #   This module can be mixed-in in any class to support attachments
  #
  #   class BlogPost
  #      include DataMapper::Resource
  #      include Model::Attachment
  #
  #      property :id, Serial, :key => true
  #      property :body, Text
  #
  #   end
  #
  #
  #   post = BlogPost.new({:body => 'Hello World!'})
  #   post.attach_from_file(storage, '/path/to/remote', '/path/to/local_file')
  #
  #
  #
  module Attachment
    include Plugins::ModelAspect
        
    def self.included(model)
    
      if model.respond_to?(:belongs_to)
        model.belongs_to :file_set_attachment, 'Model::FileSetAttachment', :parent_key => [:id], :child_key => [:file_set_attachment_id], :required => false
      end  
    
    end
     
    def save
      check_file_set_attachment! if file_set_attachment
      super
    end

    #
    # Attach a new file from a local path
    # 
    # @param [String] remote path
    # @param [String] local file path
    # @param [::Model::Storage] storage
    #
    def add_attachment_from_file(remote_path, local_file_path, storage=nil)
      
      storage ||= default_storage

      if storage.nil?
        raise 'The storage has not beed supplied and the default storage is not set up. Check attachment.default_storage'
      end

      new_attachment = nil

      transaction do |t|
        if file_set_attachment.nil?
          file_set_attachment = FileSetAttachment.create
        end
        new_attachment = file_set_attachment.add_attachment_from_file(storage, remote_path, local_file_path)
      end

      return new_attachment

    end
    
    #
    # Attach a new file from an io
    #
    # @param [String] The path in storage (remote file system)
    # @param [IO] The file to store
    # @param [Numeric] The file size
    # @param [::Model::Storage] The storage where the file attachment will be store
    #
    def add_attachment_from_io(remote_path, io, file_size, storage=nil)
      
      storage ||= default_storage

      if storage.nil?
        raise 'The storage has not beed supplied and the default storage is not set up. Check attachment.default_storage'
      end

      new_attachment = nil

      transaction do |t|
        if self.file_set_attachment.nil?
          self.file_set_attachment = FileSetAttachment.create
          self.save
        end
        new_attachment = self.file_set_attachment.add_attachment_from_io(storage, remote_path, io, file_size)
      end

      return new_attachment

    end
    
    #
    # Dettach a attachment (removing it from the database)
    #
    # @param [Numeric] The file attachment id
    #
    def remove_attachment(id, storage=nil)
    
      storage ||= default_storage

      if storage.nil?
        raise 'The storage has not beed supplied and the default storage is not set up. Check attachment.default_storage'
      end

      file_set_attachment.remove_attachment(id) if file_set_attachment
             
    end
    
    private
    
    #
    # Retrieves the default storage
    #
    # @return [Storage] The default storage
    def default_storage

      if storage_id = SystemConfiguration::Variable.get_value('attachment.default_storage')
        Storage.get(storage_id)
      end

    end

    #
    #
    #
    def check_file_set_attachment!

      if file_set_attachment and not (file_set_attachment.saved?) and loaded_file_set_attachment = FileSetAttachment.get(file_set_attachment.id)
        file_set_attachment = FileSetAttachment.get(file_set_attachment.id)
      end

    end  

  end # Attachment

end # Model