require 'daybreak'

module Docket
  module Storage
    class Daybreak < Base

      def initialize filename
        self.db = ::Daybreak::DB.new filename
      end

      def save key, value, options={}
        touch do
          db.set! key, value
          db.compact
          db.flush
        end
      end

      def append key, value
        touch do
          new_value = Array(read(key)) << value
          save(key, new_value.uniq)
        end
      end

      def remove key
        touch { db.delete! key }
      end

      def read key
        touch { db.get key }
      end

      def load
        db.load
      end

      def close
        db.close
      end

      def closed?
        db.closed?
      end

      private 

      def clear! 
        db.clear
      end

      def touch &block
        db.load
        yield if block_given?
      end
    end
  end
end
