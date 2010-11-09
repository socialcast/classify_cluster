module ClassifyCluster
  module Configurator
    class Cluster
      ROLE_2_VARIABLE_MAP = {
        'app' => ['app_servers', []],
        'db' => ['database_host', ''],
        'queue' => ['queue_host', ''],
        'push' => ['blow_server', ''],
        'search' => ['solr_host', ''],
        'munin' => ['munin_master', '']
      }
      attr_reader :nodes, :name, :classes, :variables, :resources, :hostnames
      def initialize(*args, &block)
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
          node.roles.each do |role|
            next unless ROLE_2_VARIABLE_MAP.has_key?(role.type.to_s)
            if role.type.to_s == 'munin' && role.options.has_key?('master')
              @variables['munin_master'] = node.private_ip
              next
            end
            variable_name = ROLE_2_VARIABLE_MAP[role.type.to_s].first
            variable_initial_value = ROLE_2_VARIABLE_MAP[role.type.to_s][1]
            @variables[variable_name] = variable_initial_value unless @variables.has_key?(variable_name)
            
            if @variables[variable_name].is_a?(Array)
              @variables[variable_name] << node.private_ip
            else
              @variables[variable_name] = node.private_ip
            end
          end
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
      def name(value=nil)
        return @name unless value
        @name = value
      end
      def node(node_name, private_ip, &block)
        @hostnames[node_name] = private_ip
        @nodes[node_name] = ClassifyCluster::Configurator::Node.new(node_name, private_ip, &block)
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