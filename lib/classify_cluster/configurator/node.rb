module ClassifyCluster
  module Configurator
    class Node
      attr_reader :fqdn, :variables, :resources, :classes, :public_ip, :private_ip, :roles, :default
      def initialize(*args, &block)
        @variables = {}
        @resources = []
        @classes = []
        @roles = []
        @fqdn = (args.first.to_s == 'default' ? '' : args.first)
        @default = args.first.to_s == 'default'
        block.call self
      end
      def default?
        return @default
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
  end
end