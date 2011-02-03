require 'highline/import'

module ClassifyCluster
  module Readers
    class Cli
      def self.start!(cluster_name)
        say("Welcome to classify cluster cli configurator!")
        
        gather_cluster_info(cluster_name)
        
      end
      
      def self.gather_cluster_info(cluster_name)
        cluster_name = ask("Cluster Name (no spaces): ") unless cluster_name
        cluster_info = ClassifyCluster::Configurator::Cluster.new(cluster_name) do |cluster_config|
          file_path = ask("Ssl pem path: ") do |q| 
            q.validate{ |a| File.exists?(a) }
            q.default = ClassifyCluster::Configurator::Cluster::SSLPEM_FILEPATH
          end
          module_name = ask("Puppet module to move it to: ") do |q| 
            q.default = ClassifyCluster::Configurator::Cluster::SSLPEM_MODULE
          end
          cluster_config.ssl_pem(file_path, module_name)
          
          {
            :socialcast_background_processor => 'resque',
            'socialcast_mode' => 'appliance',
            'socialcast_filestore' => 'riak',
            'cluster_name' => 'appliance-cluster',
            'deployment_root' => '/var/www/socialcast',
            'app_root' =>  '/var/www/socialcast',
            'app_shared_root' => '/var/www/socialcast',
            'app_user' => 'socialcast',
            'ssl_pem_path' => '/etc/ssl/pem',
            'app_pem_file' => 'scmc.pem',
            'cdn_disabled' => 'true',
            'solr_jvm_options' => '-server -Xmx500M -Xms64M', # Needs more granular configuration
            'rails_env' => 'production',
            'scheduler_env' => 'production',
            :backup_s3_app_name => "appliance",
            :newrelic_enabled => false,
            :solr_newrelic_app_name => "appliance",
            :newrelic_app_name => 'appliance',
            :aws_access_key_id => '',
            :aws_secret_access_key => '',
            :s3_bucket => '',
            :backup_s3_bucket => '',
            :cloudkick_oauth_key => '',
            :cloudkick_oauth_secret => '',
            :database_encoding => 'utf8',
          }.each_pair do |key, value|
            cluster_config.variable key, value
          end
          {
            :socialcast_domain => "",
            :database_username => '',
            :database_password => '',
            :database_database => '',
            :database_root_password => '',
            :flickr_key => '',
            :flickr_secret => '',
            :secret_access_key => '',
            :ldap_connections => [{
              'base' => '',
              'filter_string' => '',
              'host' => '',
              'map' => {'email' => '', 'first_name' => '', 'last_name' => '', 'company_login' => ''},
              'port' => '',
              'searcher_password' => '',
              'searcher_username' => '',
              'ssl' => ''
            }],
            :email_dropbox_account => '',
            :email_dropbox_password => '',
            :email_dropbox_host => '',
            :email_dropbox_port => '',

            :jabber_account => '',
            :jabber_password => '',

            :smtp_host => "",
            :smtp_port => '',
            :smtp_username => '',
            :smtp_password => '',
            :alert_address => ''
          }.each_pair do |key, value|
            if value.is_a?(Array)
              should_run = ask("configure #{key} (Y/n): ") do |q|
                q.default = 'n'
              end
              if running = should_run == 'Y'
                returning_values = []
                while running
                  returning_value = {}
                  value.each_pair do |subkey, subvalue|
                    if value.is_a?(Hash)
                      subreturning_value = {}
                      subvalue.each_pair do |subsubkey, subsubvalue|
                        subreturning_value[subsubkey] = ask("#{subsubkey.titleize}: ")
                      end
                      returning_value[subkey] = subreturning_value
                    else
                      returning_value[subkey] = ask("#{subkey.titleize}: ")
                    end
                  end
                  returning_values << returning_value
                end
                cluster_config.variable key, returning_values
              end
            else
              cluster_config.variable key, ask("#{key.titleize.titleize}: ")
            end
          end
        end
      end
    end
  end
end
