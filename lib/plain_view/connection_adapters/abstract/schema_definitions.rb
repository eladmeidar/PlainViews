module PlainView
  module ConnectionAdapters #:nodoc:
    # Abstract definition of a View
    class ViewDefinition
      attr_accessor :columns, :select_query, :base_model, :algorithm, :security, :check_option
      
      ALGO_TYPES = [:merge, :temptable]
      SECURITY_TYPES = [:definer, :invoker]
      CHECK_OPTIONS = [:cascaded, :local]
      
      def initialize(base)
        @columns = []
        @base = base
        @select_query = ''
      end
      
      def use_algorithm(algo_type)
        @algorithm = algo_type.to_s.upcase if ALGO_TYPES.include?(algo_type.to_sym)
      end
      
      def has_algorithm?
        @algorithm.present?
      end
      
      def use_security_mode(security_type)
        @security = security_type.to_s.upcase if SECURITY_TYPES.include?(security_type.to_sym)
      end
      
      def has_security?
        @security.present?
      end
      
      def use_check_option(check_option)
        @check_option = check_option.to_s.upcase if CHECK_OPTIONS.include?(check_option.to_sym)
      end
      
      def has_check_option?
        @check_option.present?
      end
      
      def column(name)
        column = name.to_s
        @columns << column unless @columns.include? column
        self
      end
      
      def base_model(base_model)
        begin
          @base_model = base_model.to_s.camelize.constantize
        rescue
          raise "base_model given #{base_model} is not an ActiveRecord descendent"
        end
      end
      
      def select(select_query)
        if select_query.is_a?(Hash)
          raise "You must specify a base model if you use the ActiveRecord find conventions" if @base_model.blank?
          
          @select_query = @base_model.send(:construct_finder_sql, select_query)
        elsif select_query.is_a?(String)
          @select_query = select_query
        end
      end
      
      def to_sql
        if @columns.any?
          @columns.collect { |c| @base.quote_column_name(c) } * ', '
        end
      end
      
    end
    
    class MappingDefinition
      
      # Generates a hash of the form :old_column => :new_column
      # Initially, it'll map column names to themselves.
      # use map_column to modify the list.
      def initialize(columns)
        @columns = columns
        @map = Hash.new()
        columns.each do |c|
          @map[c] = c
        end
        
      end
      
      # Create a mapping from an old column name to a new one.
      # If the new name is nil, specify that the old column shouldn't
      # appear in this new view.
      def map_column(old_name, new_name)
        unless @map.include?(old_name)
          raise ActiveRecord::ActiveRecordError, "column #{old_name} not found, can't be mapped"
        end
        if new_name.nil?
          @map.delete old_name
          @columns.delete old_name
        else
          @map[old_name] = new_name
        end
      end
      
      def select_cols
        @columns
      end
      
      def view_cols
        @columns.map { |c| @map[c] }
      end
    end
  end
end
