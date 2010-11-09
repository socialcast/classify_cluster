module ClassifyCluster
  module Configurator
    class Role
      attr_reader :type, :options
      def initialize(type, options={})
        @type = type
        @options = options
      end
      def type(value = nil)
        return @type unless value
        @type = value
      end
      def options(value = nil)
        return @options unless value
        @options = value
      end
    end
  end
end