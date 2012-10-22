require 'ysd-plugins' unless defined?Plugins::ModelAspect

module Model
 
  #
  # Attachment management module
  #
  module Attachment
    include Plugins::ModelAspect
        
    def self.included(model)
    
      if Persistence::Model.descendants.include?(model) 
        model.send :include, AttachmentPersistence
      else
        if DataMapper::Model.descendants.include?(model)
          model.send :include, AttachmentDataMapper
        end
      end
    
    end
    
    #
    # Attach a new file from a local path
    #
    # @param [::Model::Storage] storage
    # @param [String] remote path
    # @param [String] local file path
    #
    def attach_from_file(storage, remote_path, local_file_path)
      
      # Create the attachment
      file_attachment = FileAttachment::create_from_file(storage, remote_path, local_file_path)
      
      # Adds the attachment
      add_attachment(file_attachment.id)
      
    end
    
    #
    # Attach a new file from an io
    #
    # @param [::Model::Storage] storage
    # @param [String] remote_path
    # @param [IO] io
    # @param [Numeric] file_size
    #
    def attach_from_io(storage, remote_path, io, file_size)
    
      # Create the attachment
      file_attachment = FileAttachment::create_from_io(storage, remote_path, io, file_size)
      
      # Adds the attachment
      add_attachment(file_attachment.id)
        
    end
    
    #
    # Dettach a attachment
    #
    # @param [Numeric] 
    #   The file attachment id
    #
    def dettach(id)
      
      remove_attachment(file_attachment.id)

      file_attachment = FileAttachment.get(id)
      file_attachment.destroy
             
    end
    
  end # Attachment

end # Model