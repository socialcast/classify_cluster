module ClassifyCluster
  module Configurator
    class Cluster
      attr_reader :nodes, :name, :classes, :variables, :resources
      def initialize(*args, &block)
        @nodes = {}
        @variables = {}
        @resources = []
        @classes = []
        @name = args.first
        block.call self
      end
      def name(value=nil)
        return @name unless value
        @name = value
      end
      def node(node_name, &block)
        @nodes[node_name] = ClassifyCluster::Configurator::Node.new(node_name, &block)
      end
      def variable(name, value)
        @variables[name] = value
      end
      def resource(&block)
        @resources << ClassifyCluster::Configurator::Resource.new(&block)
      end
      def klass(name)
        @classes << name
      end
    end
  end
end