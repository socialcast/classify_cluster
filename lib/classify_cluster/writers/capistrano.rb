module ClassifyCluster
  module Writers
    class Capistrano
      def self.load_config(capistrano_configurator, cluster, config_file=ClassifyCluster::Base.default_config_file)
        config = ClassifyCluster::Configurator::Configuration.new(config_file).clusters[cluster]
        config.nodes.each do |node|
          roles = node.roles
          next if role.empty?
          roles.each do |role|
            capistrano_configurator.role(role.type, node.public_ip, role.options)
          end
        end
      end
    end
  end
end