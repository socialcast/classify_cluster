module ClassifyCluster
  require 'yaml'
  DEFAULT_CONFIG_LOCATION = File.join('/etc', 'cluster.yml')
  def self.get_config(hostname, options={})
    options.reverse_merge! :config_file => DEFAULT_CONFIG_LOCATION
    YAML::dump(cluster_config)
  end
  
  private
  
  def self.cluster_config(config_file)
    @@cluster_config ||= YAML.load_file(config_file)
  end
end
