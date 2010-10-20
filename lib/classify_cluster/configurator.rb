module ClassifyCluster
  module Configurator
    class Configuration
      attr_reader :clusters
      def initialize(config_path)
        @clusters = {}
        eval File.open(config_path).read
      end
      
      def cluster(cluster_name, &block)
        @clusters[cluster_name] = ClassifyCluster::Configurator::Cluster.new(&block)
      end
    end
    class Cluster
      attr_reader :nodes
      def initialize(*args, &block)
        @nodes = {}
        block.call self, *args
      end
      def node(node_name, &block)
        @nodes[node_name] = ClassifyCluster::Configurator::Node.new(&block)
      end
    end
    class Node
      attr_reader :variables, :resources, :classes, :public_ip, :private_ip, :roles
      def initialize(*args, &block)
        @variables = {}
        @resources = []
        @classes = []
        @roles = []
        block.call self, *args
      end
      def public_ip(value)
        @public_ip = value
      end
      def private_ip(value)
        @private_ip = value
      end
      def role(&block)
        @roles << ClassifyCluster::Configurator::Role.new(&block)
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
    class Resource
      attr_reader :type, :name, :options
      def initialize(*args, &block)
        @options = {}
        block.call self, *args
      end
      def type(value)
        @type = value
      end
      def name(value)
        @name = value
      end
      def options(value)
        @options = value
      end
    end
    class Role
      attr_reader :type, :options
      def initialize(*args, &block)
        @options = {}
        block.call self, *args
      end
      def type(value)
        @type = value
      end
      def options(value)
        @options = value
      end
    end
  end
end