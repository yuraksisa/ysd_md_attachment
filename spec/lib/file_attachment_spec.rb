require 'spec_helper'
require 'rspec'
require 'stringio'
require 'tempfile'

describe Model::FileAttachment do 
  
  let(:io) { StringIO.new('Hello World') }
  let(:file) do 
    f = Tempfile.new('foo') 
    f.write('Hello World!')
    f.rewind
    f
  end
  let(:storage) { Model::Storage.first_or_create({:id => 'my_google_drive', :adapter => 'googledrive'}) }
  let(:file_set_attachment) { Model::FileSetAttachment.create }
  let(:file_attachment) { Model::FileAttachment.new({:path => '/mypath', :storage => storage}) }
  
  describe "#literal_file_size" do
    
    it "should print bytes size" do
      Model::FileAttachment.new({:file_size => 30 }).literal_file_size.should == "30 bytes"
    end

    it "should print kb size" do
      Model::FileAttachment.new({:file_size => 30520 }).literal_file_size.should == "30.52 Kb"
    end

    it "should print mb size" do
      Model::FileAttachment.new({:file_size => 30265241 }).literal_file_size.should == "30.27 Mb"
    end

    it "should print gb size" do
      Model::FileAttachment.new({:file_size => 30123000000 }).literal_file_size.should == "30.12 Gb"
    end

  end

  describe "#description" do

    it "should print description" do
      Model::FileAttachment.new({:path => '/path/to/remote', :file_size => 30520}).description.should == '/path/to/remote (30.52 Kb)'
    end

  end

  describe "#upload_from_file" do
    
    it "should redirect to storage" do

      storage.should_receive(:store_from_file).with(file_attachment.path, 'path/to/local')
      file_attachment.upload_from_file('path/to/local')

    end

  end

  describe "#upload_from_io" do

    it "should redirect to storage" do

      storage.should_receive(:store_from_io).with(file_attachment.path, io)
      file_attachment.upload_from_io( io)

    end

  end

  describe "#download_to_io" do

    it "should redirect to storage" do
      
      storage.should_receive(:retrieve_to_io).with(file_attachment.path, io)
      file_attachment.download_to_io(io)

    end

  end

  describe "#download_to_file" do

    it "should redirect to storage" do

      storage.should_receive(:retrieve_to_file).with(file_attachment.path, 'path/to/local')
      file_attachment.download_to_file('path/to/local')

    end

  end

  describe ".create_from_file" do
    
    context "when using an storage" do
      
      it "should store and retrieve a file attachment" do
        # Mock the storage to avoid real access 
        storage.should_receive(:store_from_file).with('/path/to/remote', file.path)
        new_file_attachment = Model::FileAttachment.create_from_file(file_set_attachment, storage, '/path/to/remote', file.path)
      end

    end

  end

  describe ".create_from_io" do

    context "when using an storage" do
      it "should store and retrieve an IO attachment" do
        # Mock the storage to avoid real access
        storage.should_receive(:store_from_io).with('path/to/remote', io)
        storage.should_receive(:retrieve_to_io) do |path, io|
          path.should == 'path/to/remote'
          io.write 'Hello World'
        end
  
        new_file_attachment = Model::FileAttachment.create_from_io(file_set_attachment, storage, 'path/to/remote', io, io.size)
    
        new_file_attachment.download_to_io(data_io = StringIO.new)
        [data_io, io].each { |item| item.rewind }
        data_io.read.should == io.read
      end
    end
      
  end

  #after :all do
  #  file.close
  #  file.unlink
  #end

end