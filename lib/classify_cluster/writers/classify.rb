module ClassifyCluster
  module Writers
    class Classify
      def self.export!(classify_configurator)
        File.open('/etc/cluster.rb', 'w') do |file|
          output file, "# Autogenerated on #{Time.now.to_s}"
          output file, "cluster :\"#{classify_configurator.name}\" do |cluster|"

          classify_configurator.classes.each do |klass|
            output file, "cluster.klass #{klass.inspect}", 1
          end
          classify_configurator.variables.each_pair do |key, variable|
            output file, "cluster.variable #{key.inspect}, #{variable.inspect}", 1
          end

          output file, "end"
        end
      end
      
      def self.output(file, str, indent=0)
        file.write("#{"\s"*(indent*4)}#{str}\n")
      end
    end
  end
end