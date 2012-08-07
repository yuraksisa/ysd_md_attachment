require 'data_mapper' unless defined?DataMapper

module Model
  #
  # It represents a file attachment
  #
  # Usage:
  #   
  # === Define the storage or retrieve from its name
  #
  # storage = Model::Storage.create(:id=>'my_storage', :adapter=>'googledrive', :account => ::ExternalIntegration::ExternalServiceAccount.get('my_account'))
  #
  # storage = Storage.get('my_storage') 
  #
  # === Use the storage to upload files
  #
  # file_attachment = FileAttachment.create_from_file(storage, 'remote_path', 'local_path')
  #
  #
  class FileAttachment
     include DataMapper::Resource
     
     storage_names[:default] = 'attach_file_attachment'
          
     property :id, Serial, :field => 'id', :key => true
     property :path, String, :field => 'path', :length => 256
     property :file_size,  Decimal, :field => 'file_size'
     belongs_to :storage, '::Model::Storage', :child_key => [:storage_id], :parent_key => [:id] # The storage which manages the file
     
     #    
     # Retrieve the literal file size
     #
     def literal_file_size
       
       lfs = case         
               when file_size.to_f < 1000
                 ("%1.2f" % file_size.to_f) + " bytes"
               when file_size.to_f < 1000000
                 ("%1.2f" % (file_size.to_f / 1000)) + " Kb"        
               when file_size.to_f < 1000000000
                 ("%1.2f" % (file_size.to_f / 1000000)) + " Mb" 
               else
                 ("%1.2f" % (file_size.to_f / 1000000000)) + " Gb" 
             end  
     
     end
     
     #
     # Returns the description of the attachment
     #      
     def description
       "#{path} (#{literal_file_size})"
     end
     
     #
     # Create a FileAttachment from io
     #
     # @param [Storage] storage
     #   The storage
     #
     # @param [String] remote_path
     #   The path where the file will be stored in the storage
     #
     # @param [IO] io
     #   The IO to extract the data
     #
     # @return [FileAttachment]
     #
     def self.create_from_io(storage, remote_path, io, file_size=0)
       
       file_attachment = FileAttachment.new(:path => remote_path, :storage => storage, :file_size => file_size)        
       file_attachment.upload_from_io(io)
       file_attachment.save
     
       file_attachment
       
     end
     
     # 
     # Create the FileAttachment from a local file 
     #
     # @param [Storage] storage
     #   The storage
     #
     # @param [String] remote_path
     #   The path in the remote system
     #
     # @param [String] file_path
     #   The file path in the local system
     #
     def self.create_from_file(storage, remote_path, file_path)
     
       file_attachment = FileAttachment.new(:path => remote_path, :storage => storage, :file_size => File.size(file_path))
       file_attachment.upload_from_file(file_path)
       file_attachment.save
       
       file_attachment
     
     end
     
     #
     # Store the file
     #
     # @param [String] file_path
     #
     def upload_from_file(file_path)
     
       storage.store_from_file(path, file_path)
     
     end
     
     #
     # Upload the io
     #
     # @param [IO]
     #
     def upload_from_io(io)
     
       storage.store_from_io(path, io)
     
     end
     
     #
     # Download the file to a local path
     #
     def download_to_file(file_path)
       storage.retrieve_to_file(path, file_path)
     end
     
     #
     # Download the file to an io
     #
     def download_to_io(io)
     
       storage.retrieve_to_io(path, io)
     
     end
     
     #
     # Download streaming
     #
     def download_streaming(&block)
     
       storage.download_streaming(path, &block)
     
     end
     
     def to_json(opt={})
     
       methods = opt[:methods] || []
       methods << :literal_file_size
       methods << :description
     
       super(opt.merge({:methods => methods}))
     
     end
          
     #
     # After destroy, removes the resource from the storage
     #
     after :destroy do |file_attachment|
     
       file_attachment.storage.destroy(file_attachment.path) 
     
     end
          
  end
  
  
end  
