require 'highline/import'

module ClassifyCluster
  module Readers
    class Cli
      def self.start!(cluster_name, defaults_path='', variables_path='')
        say("Welcome to classify cluster cli configurator!")
        
        defaults={}
        variables={}
        File.open(defaults_path, 'r') do |file|
          defaults = eval(file.read)
        end if File.exists?(defaults_path)
        
        File.open(variables_path, 'r') do |file|
          variables = eval(file.read)
        end if File.exists?(variables_path)
        
        gather_cluster_info(cluster_name, defaults, variables)
        
      end
      
      def self.gather_value(key, value, indent=0)
        case value
        when Array
          times = 
          answers = []
          ask("#{"\t"*indent}How many #{key.to_s}: ", Integer).times do |i|
            answers << gather_value(key, value.first, 1)
            say "Configured #{i+1} #{key.to_s}"
          end
          answers
        when Hash
          ask("#{"\t"*indent}<%= @key %>: ", lambda {|ans| ans =~ /^\{\s*['|:].+$/ ? eval(ans) : ans}) do |q|
            q.gather = value
          end
        when Integer
          ask("#{"\t"*indent}#{key.to_s}: ", Integer)
        else
          ask("#{"\t"*indent}#{key.to_s}: ")
        end
      end
      
      def self.gather_cluster_info(cluster_name, defaults={}, variables={})
        cluster_name = ask("Cluster Name (no spaces): ") do |q|
          q.validate = /^\w.*/
        end unless cluster_name
        
        cluster_info = ClassifyCluster::Configurator::Cluster.new(cluster_name) do |cluster_config|
          file_path = ask("Ssl pem path: ") do |q| 
            q.validate{ |a| File.exists?(a) }
            q.default = ClassifyCluster::Configurator::Cluster::SSLPEM_FILEPATH
          end
          module_name = ask("Puppet module to move it to: ") do |q| 
            q.default = ClassifyCluster::Configurator::Cluster::SSLPEM_MODULE
          end
          cluster_config.ssl_pem(file_path, module_name)
          
          defaults.each_pair do |key, value|
            cluster_config.variable key, value
          end
          variables.each_pair do |key, value|
            cluster_config.variable key, gather_value(key, value)
          end
          
          klasses = ask("Classes: ") do |q|
            q.gather = 'q'
          end
          klasses.each do |klass|
            cluster_config.klass klass
          end
        end
      end
    end
  end
end
