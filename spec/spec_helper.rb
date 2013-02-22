#
# Before running
#
# Make sure sqlite is installed
#
#   - brew install sqlite
#
# Make sure rspec gem is installed
#
#
require 'data_mapper'
require 'ysd_md_attachment'

module DataMapper
  class Transaction
  	module SqliteAdapter
      def supports_savepoints?
        true
      end
  	end
  end
end

class BlogPost
  include DataMapper::Resource
  include Model::Attachment
  property :id, Serial, :key => true
  property :body, Text
end

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup :default, "sqlite3::memory:"
DataMapper::Model.raise_on_save_failure = true
DataMapper.finalize 

DataMapper.auto_migrate!