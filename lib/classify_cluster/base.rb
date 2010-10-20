module ClassifyCluster
  class Base
    def self.default_config_file
      File.join('/etc', 'cluster.rb')
    end
  end
end
