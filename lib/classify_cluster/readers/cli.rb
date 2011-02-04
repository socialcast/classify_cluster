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
        say "Configure cluster wide"
        cluster_config = gather_cluster_info(cluster_name, defaults, variables)
        say "Configure nodes"
        nodes = []
        ask("How many nodes: ", Integer).times do |i|
          gather_node_info!(cluster_config)
        end
        puts cluster_config.inspect
        cluster_config
      end
      
      def self.gather_value(key, value, indent=0)
        case value
        when Array
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
      
      def self.gather_node_info!(cluster_config)
        hostname = ask("Hostname: ")
        ip = ask("Ip: ")
        role_names = ClassifyCluster::Configurator::ROLES.map { |k| k.is_a?(Hash) ? k.keys.first : k }
        
        cluster_config.node(hostname, ip) do |node|
          more_roles = true
          while more_roles
            types = {}
            role_name = ask("Role [#{role_names.join(', ')}]: ", role_names)
            if ClassifyCluster::Configurator::ROLES.reject { |k| !k.is_a?(Hash) }.map(&:keys).flatten.include?(role_name)
              possible_types = ClassifyCluster::Configurator::ROLES.reject { |k| !k.is_a?(Hash) || !k.has_key?(role_name)}[0][role_name]
              more_types = true
              while more_types
                type = ask("Type [#{possible_types.join(', ')}]: ", possible_types) 
                possible_types -= [type]
                types[type] = true
                more_types = possible_types.size > 0 && agree("More types? ")
              end
            end
            node.role role_name.to_sym, types do |role|
              while agree("Role variables?")
                name = ask("name: ")
                value = ask("value: ")
                role.variable name, value
              end
            end
            role_names -= [role_name]
            more_roles = role_names.size > 0 && agree("More roles? ")
          end
        end
      end
      
      def self.gather_cluster_info(cluster_name, defaults={}, variables={})
        cluster_name = ask("Cluster Name (no spaces): ") do |q|
          q.validate = /^\w.*/
        end unless cluster_name
        
        ClassifyCluster::Configurator::Cluster.new(cluster_name) do |cluster_config|
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
          
          klasses = ask("Classes: (q to stop)") do |q|
            q.gather = 'q'
          end
          klasses.delete_if {|klass| klass.nil? || klass.empty?}.each do |klass|
            cluster_config.klass klass
          end
        end
      end
    end
  end
end
