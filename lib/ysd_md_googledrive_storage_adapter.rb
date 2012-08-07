require 'google_drive'
require 'mime/types'
require "net/https"
require "uri"
Net::HTTP.version_1_2

module Model
  #
  # Google Drive Storage Adapter
  #
  # Use:
  #
  # gd_sa = ::Model::GoogledriveStorageAdapter.new(account)
  # gd_sa.store_file('my_file', localpath)
  # gd_sa.retrieve_file_to_file('my_file', local_path)  
  #
  class GoogledriveStorageAdapter
  
    def initialize(account)
      @account = account
    end
    
    #
    # Store the io in Google Drive
    #
    def store_io(file_path, io)
      if gd_file=get_file(file_path)
        file_name, directory = extract_path_parts(file_path)
        gd_file.update_from_io(io, gd_options(file_name))
      else
        gd_file=create_file_from_io(file_path, io)
      end    
    end
    
    #
    # Store the file in Google Drive
    #
    # 
    def store_file(file_path, local_file_path)
    
      if gd_file=get_file(file_path)
        file_name, directory = extract_path_parts(file_path)
        gd_file.update_from_file(local_file_path, gd_options(file_name))
      else
        gd_file=create_file_from_file_path(file_path, local_file_path)
      end
      
    end
    
    #
    # Retrive the file from Google Drive
    #
    # @param [String] file_path
    #
    def retrieve_file_to_io(file_path, io)
    
      if gd_file=get_file(file_path)
        gd_file.download_to_io(io)
      end
      
    end
    
    #
    # Retrieve the file from Google Drive to the local_file_path
    #
    # @param [String] file_path
    #   The google drive resource path
    #
    # @param [String] local_file_path
    #   The local path where store the file
    #
    def retrieve_file_to_file(file_path, local_file_path)
    
      if gd_file=get_file(file_path)
        gd_file.download_to_file(local_file_path)
      end
    
    end

    #
    # Delete the resource from Google Drive
    #
    # @param [String file_path]
    #
    def delete_file(file_path)
      if gd_file=get_file(file_path)
        gd_file.delete
      end
    end
    
    #
    # Gets the external URL from the file
    #
    def file_url(file_path)
    
      url = nil
    
      if gd_file=get_file(file_path)
        url = gd_file.document_feed_entry.css("content")[0]["src"]
      else
        puts "fichero no existe"
      end
      
      url
      
    end

    #
    # Download the file
    #
    def download_streaming(file_path)
      
      url = file_url(file_path)
      
      token = get_session.auth_tokens[:writely]
      
      url = url.gsub(%r{^http://}, "https://") # Always uses HTTPS.
      uri = URI.parse(url)
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      http.start() do
         path = uri.path + (uri.query ? "?#{uri.query}" : "")
         header = {"Authorization" => "GoogleLogin auth=#{token}"}
         http.get(path, header) do |str|
           yield str if block_given?
         end         
      end
    
    end

    private
     
    #
    # Get the google drive session
    # 
    def get_session
    
      unless @session
        @session = GoogleDrive.login(@account.username, @account.password)
      end
      
      @session
    
    end 
        
    #
    # Get the file
    #
    # @return [GoogleDrive::File] the file
    #
    def get_file(path)
     
     file_name, directory = extract_path_parts(path)
     
     if directory 
        
       folder = get_session.files(:showfolders => 'true', :title => directory.first).first

       if directory.size > 1
         directory.slice(1, directory.size).each do |folder_name|
           folder = folder.files('title' => folder_name).first
         end
       end

     else
       file_name = path
       
       folder = get_session.root_collection
     end
        
     file = folder.files('title' => file_name).first 

    end
    
    #
    # Creates the file from an IO
    #
    # @param [String] path
    #  The remote path
    #
    # @param [IO] io
    #  The io to read the file from
    #
    def create_file_from_io(path, io)

      file_name, directory = extract_path_parts(path)            
      gd_file = get_session.upload_from_io(io, file_name, gd_options(file_name))
      move_file(gd_file, directory) if directory

      gd_file
          
    end
    
    #
    # Creates a file from a file path
    #
    # @param [String] path
    #  The remote path (in Google Drive)
    #
    # @param [String] local_file_path
    #
    def create_file_from_file_path(path, local_file_path)
   
      file_name, directory = extract_path_parts(path)      
      gd_file = get_session.upload_from_file(local_file_path, file_name, gd_options(file_name))
      move_file(gd_file, directory) if directory
      
      gd_file 
    end
    
    #
    # Configure google drive options
    #
    def gd_options(file_name)
    
      options = {}
      
      # Not convert images 
      
      if MIME::Types.type_for(file_name).first.media_type == 'image'
        options.store(:convert,false)
      end
      
      options
    
    end
    
    #
    # Move a file in the remote structure
    #
    # @param [GoogleDrive::File] the file to move
    #
    # @param [Array] the destination folder
    # 
    def move_file(gd_file, destination)
        
      folder = get_session.root_collection
      
      destination.each do |destination_folder|
        folder = folder.files('title' => destination_folder).first
      end
      
      if folder
        folder.add(gd_file)
        #gd_file.delete(true)
      end
    
    end
    
    #
    # Extract the parts from a path : folder and filename
    #
    def extract_path_parts(path)
     result = []
     if tmp=path.split('/')
       result << tmp.last
       result << tmp.slice(1, tmp.size-2)         
     else
       result << path
       result << nil
     end      
     result
    end
      
  
  end #GoogledriveStorageAdapter
end #Model