require 'fileutils'
require 'active_support'
module ClassifyCluster
  module Writers
    class Puppet
      def self.export!(export_to_folder, options={})
        options.reverse_merge! :config_file => ClassifyCluster::Base.default_config_file
        config = ClassifyCluster::Configurator::Configuration.new(options[:config_file])
        config.clusters.each_pair do |name, cluster|
          
          next if options[:cluster] && !(options[:cluster] == cluster.name.to_s)
          
          pem_file = "/etc/puppet/modules/#{cluster.ssl_pem[:module]}/files/#{cluster.name.to_s}.#{File.basename(cluster.ssl_pem[:file_path])}"
          FileUtils.cp cluster.ssl_pem[:file_path], pem_file
          FileUtils.chown 'root', 'puppet', pem_file
          FileUtils.chmod 0640, pem_file
          
          File.open(File.join(export_to_folder, "#{cluster.name}.pp"), 'w') do |file|
            cluster.nodes.each_pair do |fqdn, node|
              file.write(output(%Q%node "#{node.default? ? 'default' : node.fqdn}" {%))
              cluster.variables.each_pair do |key, value|
                file.write(output("$#{key}=#{value.inspect}", :indent => 1))
              end
              node.variables.each_pair do |key, value|
                file.write(output("$#{key}=#{value.inspect}", :indent => 1))
              end
              cluster.resources.each do |resource|
                file.write(output("#{resource.type} { #{resource.name.inspect}:", :indent => 1))
                resource.options.each_pair do |key, value|
                  file.write(output("#{key} => #{value.inspect},", :indent => 2))
                end
                file.write(output("}", :indent => 1))
              end
              node.resources.each do |resource|
                file.write(output("#{resource.type} { #{resource.name.inspect}:", :indent => 1))
                resource.options.each_pair do |key, value|
                  file.write(output("#{key} => #{value.inspect},", :indent => 2))
                end
                file.write(output("}", :indent => 1))
              end
              cluster.classes.each do |klass|
                file.write(output("include #{klass}", :indent => 1))
              end
              node.classes.each do |klass|
                file.write(output("include #{klass}", :indent => 1))
              end
              file.write(output("include socialcast::onpremise", :indent => 1))
              file.write(output("}\n"))
            end
          end
        end; nil
      end
      private
      def self.output(string, options={})
        options.reverse_merge! :indent => 0
        %Q%#{("\s" * 2) * options[:indent]}#{string}\n%
      end
    end
  end
end