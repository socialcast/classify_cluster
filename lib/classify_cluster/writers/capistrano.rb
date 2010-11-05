module ClassifyCluster
  module Writers
    class Capistrano
      def self.export!(capistrano_configurator, cluster, config_file=ClassifyCluster::Base.default_config_file)
        config = ClassifyCluster::Configurator::Configuration.new(config_file).clusters[cluster]
        config.variables.each_pair do |name, value|
          capistrano_configurator.set("puppet-#{name}".to_sym, value)
        end
        config.nodes.each_pair do |name, node|
          roles = node.roles
          next if roles.empty?
          roles.each do |role|
            capistrano_configurator.role(role.type, node.public_ip, role.options)
          end
        end
      end
    end
  end
end