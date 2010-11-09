module ClassifyCluster
  module Writers
    class Capistrano
      CLUSTER_ROLE_2_CAP_ROLE = {
        'db' => 'db',
        'queue' => 'rabbitmq',
        'cron' => 'cron',
        'app' => 'app',
        'worker' => 'workling',
        'munin' => 'munin',
        'web' => 'web',
        'push' => 'push',
        'puppet_master' => 'puppet_master',
        'search' => 'solr'
      }
      def self.export!(capistrano_configurator, cluster, config_file=ClassifyCluster::Base.default_config_file)
        config = ClassifyCluster::Configurator::Configuration.new(config_file).clusters[cluster]
        config.variables.each_pair do |name, value|
          capistrano_configurator.set("puppet-#{name}".to_sym, value)
        end
        config.nodes.each_pair do |name, node|
          roles = node.roles
          next if roles.empty?
          roles.each do |role|
            capistrano_configurator.role((CLUSTER_ROLE_2_CAP_ROLE[role.type.to_s] || role.type.to_s), node.fqdn, role.options)
          end
        end
      end
    end
  end
end