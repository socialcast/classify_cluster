module ClassifyCluster
  module Writers
    class Classify
      
      def self.export!(classify_configurator)
        puts classify_configurator.inspect
        
      end
    end
  end
end