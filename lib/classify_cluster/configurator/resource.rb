module ClassifyCluster
  module Configurator
    class Resource
      attr_reader :type, :name, :options
      def initialize(*args, &block)
        @options = {}
        block.call self
      end
      def type(value = nil)
        return @type unless value
        @type = value
      end
      def name(value = nil)
        return @name unless value
        @name = value
      end
      def options(value = nil)
        return @options unless value
        @options = value
      end
    end
  end
end