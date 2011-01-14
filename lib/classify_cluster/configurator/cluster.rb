module ClassifyCluster
  module Configurator
    class Cluster
      attr_reader :nodes, :name, :classes, :variables, :resources, :hostnames, :ssl_pem
      def initialize(*args, &block)
        @ssl_pem = {:file_path => '/etc/ssl/pem/scmc.pem', :module => 'loadbalancer'}
        @nodes = {}
        @variables = {}
        @resources = []
        @classes = []
        @name = args.first
        @hostnames = {}
        returned = block.call(self)
        @nodes.each_pair do |fqdn, node|
          @variables['hostnames'] = [] unless @variables['hostnames']
          @variables['hostnames'] << "#{fqdn}/#{node.private_ip}"
        end
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
        returned
      end
      def ssl_pem(file_path=nil, module_name=nil)
        return @ssl_pem if file_path.nil? && module_name.nil?
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
    end
  end
end