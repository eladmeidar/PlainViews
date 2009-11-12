module PlainView
  module Loader
    SUPPORTED_ADAPTERS = %w( Mysql PostgreSQL SQLServer SQLite )

    def self.load_extensions
      SUPPORTED_ADAPTERS.each do |db|
        if ActiveRecord::ConnectionAdapters.const_defined?("#{db}Adapter")
          require "plain_view/connection_adapters/#{db.downcase}_adapter"
          ActiveRecord::ConnectionAdapters.const_get("#{db}Adapter").class_eval do
            include PlainView::ConnectionAdapters::AbstractAdapter
            include PlainView::ConnectionAdapters.const_get("#{db}Adapter")
          end
        end
      end
    end
  end
end
