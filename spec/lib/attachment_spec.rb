require 'spec_helper'
require 'ysd_md_configuration' unless defined?SystemConfiguration::Variable

describe Model::Attachment do 

  let(:file) { StringIO.new('Hello World') }
  let(:storage) { Model::Storage.first_or_create({:id => 'my_google_drive_3'}, {:adapter => 'googledrive'}) }
  let(:post) { BlogPost.create({:body => 'Blog post'}) }

  describe ".add_attachment_from_io" do
 
    context "when storage specified or default storage set up" do

      it "should add the attachment" do
       # Mock storage
        storage.should_receive(:store_from_io).with('path/to/remote3', file)
        storage.should_receive(:retrieve_to_io) do |path, io|
          path.should == 'path/to/remote3'
          io.write 'Hello World'
        end

        file_attachment = post.add_attachment_from_io('path/to/remote3', file, file.size, storage)
        file_attachment.download_to_io(data_io = StringIO.new)

        [data_io, file].each { |item| item.rewind }
        data_io.read.should == file.read        
      end

      it "should use the default storage" do
        # Mock storage
        storage.should_receive(:store_from_io).with('path/to/remote4', file)
        storage.should_receive(:retrieve_to_io) do |path, io|
          path.should == 'path/to/remote4'
          io.write 'Hello World'
        end
        # Mock post (to use default storage)
        post.should_receive(:default_storage).and_return(storage)
    
        file_attachment = nil 
        expect {file_attachment = post.add_attachment_from_io('path/to/remote4', 
                                                              file, 
                                                              file.size)}.not_to raise_error

        file_attachment.download_to_io(data_io = StringIO.new)

        # Check the content
        [data_io, file].each { |item| item.rewind }
        data_io.read.should == file.read
      end

    end

    context "when not storage assigned and not default storage setup" do

      it "should raise an exception" do
        expect {post.add_attachment_from_io('path/to/remote4', file, file.size)}.to raise_error
      end
  
    end
  
  end

  describe ".remove_attachment" do

  end

end