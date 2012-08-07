require 'data_mapper' unless defined?DataMapper

module Model
  #
  # It represents a file storage system
  # 
  # It exists an instance for each of the accounts/system
  #
  # storage = Model::Storage.create(:id => 'gd_yurak', :account => ExternalIntegration::ExternalServiceAccount.get('myaccount'), :adapter => 'googledrive')
  # storage.store_file(
  #
  #
  class Storage
    include DataMapper::Resource
    
    storage_names[:default] = 'attach_storage'
    
    property :id, String, :field => 'id', :length => 32, :key => true
    property :adapter, String, :field => 'adapter', :length => 32
    belongs_to :account, 'ExternalIntegration::ExternalServiceAccount', :child_key => ['account_id'], :parent_key => ['id'], :required => false
        
    #
    # Stores the file
    #
    # @param [String] remote_path
    #   The file path in the storage system
    #
    # @param [String] file
    #   The local path of file to store 
    #
    def store_from_file(remote_path, local_file_path)
      get_adapter.store_file(remote_path, local_file_path)
    end    
    
    #
    # Store the content from the io
    #
    def store_from_io(remote_path, io)
      get_adapter.store_io(remote_path, io)
    end
    
    #
    # Retrieve the file
    #
    # @param [String] remote_path
    #   The file path in the storage system
    #
    # @param [IO] io
    #   The io where the file will be stored
    #
    def retrieve_to_io(remote_path, io)
      get_adapter.retrieve_file_to_io(remote_path, io)
    end
    
    #
    # Retrieve the file to the local storage
    #
    def retrieve_to_file(remote_path, local_file_path)
      get_adapter.retrieve_file_to_file(remote_path, local_file_path)
    end
    
    #
    # Destroy the file from the remote storage
    #
    def destroy(remote_path)
      get_adapter.delete_file(remote_path)
    end
    
    #
    # Retrieve the file url from the path
    #
    def file_url(remote_path)
      get_adapter.file_url(remote_path)
    end
    
    #
    # Download streaming
    #
    def download_streaming(remote_path, &block)
    
      get_adapter.download_streaming(remote_path, &block)

    end
    
    private
    
    #
    # Get the adapter instance
    #
    def get_adapter
    
      unless @remote_adapter
        @remote_adapter = adapter_class(adapter).new(account)
      end
      
      @remote_adapter
    
    end
      
    # return the adapter class constant
    #  
    # adapter_class('Googledrive') => Model::GoogledriveStorageAdapter
    #
    def adapter_class(name)
       class_name = (name.downcase.capitalize<<'StorageAdapter').to_sym
       load_adapter(name.downcase) unless ::Model.const_defined?(class_name)
       ::Model.const_get(class_name)
    end
    
    # require the adapter library
    #
    def load_adapter(name)
       require "ysd_md_#{name}_storage_adapter"
    end
      
      
  end
end
