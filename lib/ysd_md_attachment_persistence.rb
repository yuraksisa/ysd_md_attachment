module Model
 
  #
  # It's a module you can include in your class to manage attachments
  #
  module AttachmentPersistence
  
    def self.included(model)
      model.property :attachments
    end
            
    #
    # Adds an existing attachment
    #
    def add_attachment(attachment_id) 
      element_attachments = Array(attribute_get(:attachments)) || []
      element_attachments << file_attachment.id
      
      # Sets the attachments
      attribute_set(:attachments, element_attachments)    
    end
    
    #
    # Removes an attachment reference
    #
    def remove_attachment(attachment_id)
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
      
      current_attachments = attribute_get(:attachments) || []
    
      if current_attachments == '' #TODO a bug in persitence (CHECK SOON)
        current_attachments = []
      end
      
      if not @old_attachments.nil? 
         removed_attachments = @old_attachments - current_attachments
         new_attachments = current_attachments - @old_attachments 
      end
      
      super

      unless removed_attachments.nil?
        FileAttachment.all(:id => removed_attachments).destroy
      end
      
      # TODO move the new attachments from the temp folder
      
    end 

    # Overwritten to hash the password 
    #
    def attribute_set(name, value)  
      if (name.to_sym == :attachments)
        value = [] if value == ''  #TODO a bug in persitence (CHECK SOON)
        @old_attachments = attribute_get(:attachments) || []
        if @old_attachments == ''  #TODO a bug in persitence (CHECK SOON)
          @old_attachments = []
        end
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