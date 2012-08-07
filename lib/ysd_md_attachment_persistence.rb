module Model
 
  #
  # Attachment management module
  #
  module Attachment
  
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
    
  end

  #
  # It's a module you can include in your class to manage attachments
  #
  module AttachmentPersistence
    include Attachment
  
    def self.included(model)
      model.property :attachments
    end
            
    #
    # Adds an existing attachment
    #
    def add_attachment(attachment_id) 
      element_attachments = Array(attribute_get(:attachment)) || []
      element_attachments << file_attachment.id
      
      # Sets the attachments
      attribute_set(:attachments, element_attachments)    
    end
    
    #
    # Removes an attachment reference
    #
    def remote_attachment(attachment_id)
      attribute_get(:attachments).delete(attachment_id)
    end    

    #
    # Retrieve the attachments
    #
    def get_attachments
      
      unless @file_attachments
       @file_attachments = if attribute_get(:attachments)
                             ::Model::FileAttachment.all(:id => attribute_get(:attachments))
                           else
                             []
                           end
      end

      @file_attachments
    
    end    
        
    #
    # Create the resource
    #
    def create
      
      super
 
      # TODO move the new attachaments from the temp folder
           
    end
    
    #
    # Update the resource
    #
    def update
      
      removed_attachments = nil
      new_attachments = nil
      
      if @old_attachments
         removed_attachments = @old_attachments - attribute_get(:attachements)
         added_attachments = attribute_get(:attachments) - @old_attachments 
      end
      
      super

      if removed_attachments
        FileAttachment.all(:id => removed_attachments).destroy
      end
      
      # TODO move the new attachments from the temp folder
      
    end 

    # Overwritten to hash the password 
    #
    def attribute_set(name, value)  
      if (name.to_sym == :attachments)
        @old_attachments = attribute_get(:attachments)
      end

      super(name, value)
    end
     
    #
    # Override the exportable attributes to retrieve a list of the attributes
    #
    def exportable_attributes
      
      the_attributes = super
      the_attributes.store(:attachments, get_attachments) 
      
      the_attributes
    
    end 
         
  end #AttachmentPersistence
end #Model