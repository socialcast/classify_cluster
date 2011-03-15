require 'yaml'
module ClassifyCluster
  module Configurator
    class Configuration
      attr_reader :clusters
      def initialize(config_path)
        @clusters = {}
        case File.extname(config_path)
        when ".rb"
          eval File.open(config_path).read
        when ".yml"
          config = YAML.load_file(config_path)
          config.each_pair do |cluster_name, cluster_values|
            cluster(cluster_name) do |cluster|
              cluster_values['klasses'].each do |klass|
                cluster.klass klass
              end
              cluster_values['variables'].each_pair do |variable_name, variable_value|
                cluster.variable variable_name, variable_value
              end
              cluster_values['nodes'].each do |node_values|
                cluster.node(node_values['hostname'], node_values['ip_address']) do |node|
                  node_values['roles'].each_pair do |role_name, role_values|
                    options={}
                    options['primary'] = true if role_values.delete('primary')
                    options['backup'] = true if role_values.delete('backup')
                    options['master'] = true if role_values.delete('master')
                    options['node'] = true if role_values.delete('node')
                    node.role(role_name, options) do |role|
                      role_values.each_pair do |role_value_name, role_value|
                        role.variable role_value_name, role_value
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
      
      def cluster(cluster_name, &block)
        @clusters[cluster_name] = ClassifyCluster::Configurator::Cluster.new(cluster_name, &block)
      end
    end
  end
end