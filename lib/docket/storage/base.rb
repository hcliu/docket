module Docket
  module Storage
    class Base
      attr_accessor :db, :namespace

      def initialize args={}
        self.namespace = args[:namespace] || Docket.configuration.storage_namespace
      end

      def save key, value, options={}
      end

      def append key, value
      end

      def remove key
      end

      def read key
      end

      def load
      end

      def close
      end

      def closed?
      end

      def clear! 
      end

      private 

      def namespaced key
        [self.namespace, key].compact.join(":")
      end

      def clean key
        key.gsub("#{self.namespace}:", "")
      end

      def touch &block
      end
    end
  end
end
