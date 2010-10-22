module ClassifyCluster
  module Configurator
    class Cluster
      attr_reader :nodes, :name
      def initialize(*args, &block)
        @nodes = {}
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
    end
  end
end