module ClassifyCluster
  module Configurator
    class Configuration
      attr_reader :clusters
      def initialize(config_path)
        @clusters = {}
        eval File.open(config_path).read
      end
      
      def cluster(cluster_name, &block)
        @clusters[cluster_name] = ClassifyCluster::Configurator::Cluster.new(cluster_name, &block)
      end
    end
    class Cluster
      attr_reader :nodes, :name
      def initialize(*args, &block)
        @nodes = {}
        @name = args.first
        block.call self, *args
      end
      def name(value=nil)
        return @name unless value
        @name = value
      end
      def node(node_name, &block)
        @nodes[node_name] = ClassifyCluster::Configurator::Node.new(node_name, &block)
      end
    end
    class Node
      attr_reader :fqdn, :variables, :resources, :classes, :public_ip, :private_ip, :roles
      def initialize(*args, &block)
        @variables = {}
        @resources = []
        @classes = []
        @roles = []
        @fqdn = args.first
        block.call self, *args
      end
      def fqdn(value=nil)
        return @fqdn unless value
        @fqdn = value
      end
      def public_ip(value = nil)
        return @public_ip unless value
        @public_ip = value
      end
      def private_ip(value = nil)
        return @private_ip unless value
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
    class Role
      attr_reader :type, :options
      def initialize(*args, &block)
        @options = {}
        block.call self, *args
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