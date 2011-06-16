module ClassifyCluster
  module Writers
    class Capistrano
      CLUSTER_ROLE_2_CAP_ROLE = {
        'db' => 'db',
        'queue' => 'queue',
        'cron' => 'cron',
        'app' => 'app',
        'worker' => 'workling',
        'munin' => 'munin',
        'web' => 'web',
        'push' => 'push',
        'puppet_master' => 'puppet_master',
        'search' => 'elasticsearch',
        'file' => 'file',
        'scheduler' => 'scheduler'
      }
      def self.export!(capistrano_configurator, cluster, config_file=ClassifyCluster::Base.default_config_file)
        config = ClassifyCluster::Configurator::Configuration.new(config_file).clusters[cluster]
        config.variables.each_pair do |name, value|
          capistrano_configurator.set("puppet_#{name}".to_sym, value)
        end
        config.nodes.each_pair do |name, node|
          roles = node.roles
          next if roles.empty?
          
          roles.each do |role|
            role_name = (CLUSTER_ROLE_2_CAP_ROLE[role.type.to_s] || role.type.to_s)
            capistrano_configurator.role(role_name, node.fqdn, role.options)
            if role_name == 'puppet_master'
              capistrano_configurator.set("puppet_role_puppet_master_fqdn", node.fqdn)
              capistrano_configurator.set("puppet_role_puppet_master_private_ip", node.private_ip)
            end
          end
        end
      end
    end
  end
end