module ActiveRecord
  class Base
    cattr_accessor :enablePersistentQueryCacheForModels
    self.enablePersistentQueryCacheForModels ||= {}

    def clear_persistent_cache
      # Expire all the possible cached keys for this model
      self.class.column_names.select {|c| c =~ /^[A-Za-z_]*_?id$/ }.each do |c|
        id = self.read_attribute(c)
        Rails.logger.debug("Deleting #{self.class.table_name}_#{c}_#{id} from persistent cache")
        ::Rails.cache.delete("#{self.class.table_name}_#{c}_#{id}")
      end
    end

    class << self
      # Call this to enable the persistent query cache
      def enable_persistent_query_cache(options = {})
        if ActionController::Base.perform_caching && defined?(::Rails.cache)
          self.enablePersistentQueryCacheForModels[self.base_class.name] = options
          after_save :clear_persistent_cache
          after_destroy :clear_persistent_cache
        end
      end

      def connection_with_persistent_query_cache
        conn = connection_without_persistent_query_cache
        conn.persistent_query_cache_options = self.enablePersistentQueryCacheForModels[self.to_s]
        conn
      end

      alias_method_chain :connection, :persistent_query_cache
    end
  end

  module ConnectionAdapters # :nodoc:
    class AbstractAdapter
      attr_accessor :persistent_query_cache_options
    end

    module QueryCache
      private

        def cache_sql(sql, binds)
          result =
            if @query_cache[sql].has_key?(binds)
              ActiveSupport::Notifications.instrument("sql.active_record",
                                                      :sql => sql, :name => "Cache", :connection_id => self.object_id)
              @query_cache[sql][binds]
            elsif self.persistent_query_cache_options && cached_result = retrieve_from_persistent_cache(sql)
              @query_cache[sql][binds] = cached_result
            else
              query_result = yield
              if self.persistent_query_cache_options && key = persistent_cache_key(sql)
                ::Rails.cache.write(key, query_result, self.persistent_query_cache_options)
              end
              @query_cache[sql][binds] = query_result
            end

          result.collect { |row| row.dup }
        end

        def retrieve_from_persistent_cache(sql)
          if key = persistent_cache_key(sql)
            ActiveSupport::Notifications.instrument("sql.active_record",
                                                       :sql => sql, :name => "Persistent Cache", :connection_id => self.object_id) do
              ::Rails.cache.fetch(key)
            end
          end
        end

        def persistent_cache_key(sql)
          # SQL should be of the form - SELECT  `table_name`.* FROM `table_name`  WHERE `table_name`.`id` = 1854 LIMIT 1
          match = sql.match(/SELECT\s+`\w+`\.\*\s+FROM\s+`([A-Za-z_]+)`\s+WHERE\s+`([A-Za-z_]+)`\.`([A-Za-z_]*_?id)` = (\d+)\s+LIMIT 1/)
          return nil unless match
          # key is 'table_column_id'
          "#{match[1]}_#{match[3]}_#{match[4]}"
        end
    end
  end
end