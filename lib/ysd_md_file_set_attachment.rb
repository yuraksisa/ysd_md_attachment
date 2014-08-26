require 'data_mapper' unless defined?DataMapper

module Model
  # 
  # It represents a set of attachments that can be tied to any element that support 
  # attachments.
  #	
  class FileSetAttachment
  	include DataMapper::Resource
    
    storage_names[:default] = 'attach_fileset_attachments'

    property :id, Serial, :field => 'id', :key => true
    property :name, String, :field => 'name', :length => 80
    property :root, Boolean, :field => 'boolean', :default => true
    has n, :file_attachments, 'FileAttachment', :child_key => [:file_set_attachment_id], :parent_key => [:id]

    #
    # Attach a new file from a local path
    #
    # @param [::Model::Storage] storage
    # @param [String] remote path
    # @param [String] local file path
    #
    # @return [FileAttachment] The new created attachment
    #
    def add_attachment_from_file(storage, remote_path, local_file_path)
      
      file_attachment = nil

      transaction do |t|
        file_attachment = FileAttachment::create_from_file(self, storage, remote_path, local_file_path)
        file_attachments << file_attachment
        save
      end

      return file_attachment

    end
    
    #
    # Attach a new file from an io
    #
    # @param [::Model::Storage] The storage where the file attachment will be store
    # @param [String] The path in storage (remote file system)
    # @param [IO] The file to store
    # @param [Numeric] The file size
    #
    # @return [FileAttachment] the new created attachment
    def add_attachment_from_io(storage, remote_path, io, file_size)
      
      file_attachment = nil

      transaction do |t|
        file_attachment = FileAttachment::create_from_io(self, storage, remote_path, io, file_size)
        file_attachments << file_attachment
        save
      end

      return file_attachment

    end
    
    #
    # Dettach a attachment (removing it from the database)
    #
    # @param [Numeric] The file attachment id
    #
    def remove_attachment(id)
      
      transaction do |t|
        file_attachment = FileAttachment.get(id)
        file_attachment.destroy
        save
        t.commit
      end

    end
    
    def as_json(opts={})

      methods = opts[:methods] || []
      methods << :file_attachments

      super(opts.merge(:methods => methods))

    end


  end #FileSetAttachment
end #Model