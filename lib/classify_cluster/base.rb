module ClassifyCluster
  class Base
    def self.default_config_file
      cluster_rb = File.join('/etc', 'cluster.rb')
      cluster_yml = File.join('/etc', 'cluster.yml')
      if !File.exists?(cluster_rb) && File.exists?(cluster_yml)
        cluster_yml
      else
        cluster_rb
      end
    end
  end
end
