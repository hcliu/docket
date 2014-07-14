require 'redis'
require 'msgpack'

module Docket
  module Storage
    class Redis < Base

      def initialize options={}
        super
        self.db = options[:redis] || ::Redis.new
      end

      def save key, value, options={}
        save_packed key, value
      end

      def append key, value
        if read(key).nil?
          save(key, Array(value))
        else
          current = read(key)
          new_value = Array(current) << value
          save(key, new_value.uniq)
        end        
      end

      def remove key
        redis.del(namespaced(key))
      end

      def read key
        read_packed key
      end

      def clear! 
        keys = keys_context
        redis.del(*keys) unless keys.empty?
      end

      def describe
        keys_context.map do |key|
          [key, read(clean(key))]
        end
      end

      private

      def keys_context
        redis.keys "#{namespace}:*"
      end

      def save_packed key, value
        redis.set(namespaced(key), MessagePack.pack(value))
      end

      def read_packed key
        value = redis.get(namespaced(key))
        if value
          MessagePack.unpack(value) 
        else
          nil
        end
      end

      def redis
        self.db
      end

    end
  end
end
