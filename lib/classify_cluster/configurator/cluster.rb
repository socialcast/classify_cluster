module ClassifyCluster
  module Configurator
    class Cluster
      SSLPEM_FILEPATH = '/etc/ssl/pem/scmc.pem'
      SSLPEM_MODULE = 'loadbalancer'
      attr_reader :nodes, :name, :classes, :variables, :resources, :hostnames, :ssl_pem
      def initialize(*args, &block)
        @ssl_pem = {}
        @nodes = {}
        @variables = {}
        @resources = []
        @classes = []
        @name = args.first
        @hostnames = {}
        returned = block.call(self)
        add_hostnames
        add_node_roles
        returned
      end
      def ssl_pem(file_path=nil, module_name=nil)
        if file_path.nil? && module_name.nil?
          @ssl_pem = {:file_path => SSLPEM_FILEPATH, :module => SSLPEM_MODULE}
          return @ssl_pem
        end
        @ssl_pem = {:file_path => file_path, :module => module_name}
      end
      def name(value=nil)
        return @name unless value
        @name = value
      end
      def node(node_name, private_ip, &block)
        @hostnames[node_name] = private_ip
        @nodes[node_name] = ClassifyCluster::Configurator::Node.new(node_name, private_ip, self, &block)
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
      def add_hostnames
        @nodes.each_pair do |fqdn, node|
          @variables['hostnames'] = [] unless @variables['hostnames']
          @variables['hostnames'] << "#{fqdn}/#{node.private_ip}"
        end
      end
      def add_node_roles
        @nodes.each_pair do |fqdn, node|
          node.resource do |resource|
            resource.type 'etchosts'
            resource.name "hosts"
            resource.options({
              :short_name => fqdn.split('.').first,
              :fqdn => fqdn,
              :hosts => @variables['hostnames']
            })
          end
        end
      end
    end
  end
end