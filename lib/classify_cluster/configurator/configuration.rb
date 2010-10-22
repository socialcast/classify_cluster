module ClassifyCluster
  module Configurator
    class Configuration
      attr_reader :clusters
      def initialize(config_path)
        @clusters = {}
        eval File.open(config_path).read
      end
      
      def cluster(cluster_name, &block)
        @clusters[cluster_name] = ClassifyCluster::Configurator::Cluster.new(cluster_name, &block)
      end
    end
  end
end