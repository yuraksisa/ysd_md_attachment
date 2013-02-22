require 'spec_helper'

describe Model::FileSetAttachment do 
  
  let(:file) { StringIO.new('Hello World') }
  let(:storage) { Model::Storage.first_or_create({:id => 'my_google_drive_2', :adapter => 'googledrive'}) }
  
  #describe "#add_attachment_from_file" do
  #
  #end

  describe "#add_attachment_from_io" do
    
    context "when using an storage" do

      it "should create the file set attachment" do
        # Mock the storage to avoid accesing google drive
        storage.should_receive(:store_from_io).with('path/to/remote2', file)
        storage.should_receive(:retrieve_to_io) do |path, io|
          path.should == 'path/to/remote2'
          io.write 'Hello World'
        end
    
        # Create an attachment 
        file_set_attachment = Model::FileSetAttachment.create
        file_attachment = file_set_attachment.add_attachment_from_io(storage, 'path/to/remote2', file, file.size)
        file_attachment.download_to_io(data_io = StringIO.new)
    
        [data_io, file].each { |item| item.rewind }
        data_io.read.should == file.read
      end

    end

  end

end