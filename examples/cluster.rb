# classify_cluster v.0.0.3a
cluster_common = %w{ ntp conary sysstat }
onpremise_common = %w{ sudo::onpremise cron::onpremise monit::onpremise logrotate::onpremise }

cluster :"appliance-cluster" do |cluster|
  (cluster_common + onpremise_common).each do |common_class|
    cluster.klass common_class
  end
  {  
    
    # Cluster-wide configuration variables
    
    :socialcast_domain => "localhost.localdomain",
    :database_username => 'socialcast',
    :database_password => '',
    
    :database_root_password => '',
    
    :flickr_key => '',
    :flickr_secret => '',
    
    :email_dropbox_account => '',
    :email_dropbox_password => '',
    
    :jabber_account => '',
    :jabber_password => '',
    
    :smtp_gateway_address => "foobar.local",
    :smtp_gateway_port => '493',
    :smtp_gateway_tls_enabled => 'true',
    :smtp_gateway_anonymous_access_enabled => 'true',
    :smtp_gateway_username => 'foo@bar',
    :smtp_gateway_password => 'bazquux',
    
    :email_dropbox_server => '',
    :email_dropbox_port => '993',
    :innodb_buffer_pool_size => '100M',
    :number_of_rails => '3',
    :number_of_worklings => '2',
    
    
    # Defaults
    'socialcast_mode' => 'appliance',
    'socialcast_filestore' => 'secure_file_system',
    'cluster_name' => 'appliance-cluster',
    'deployment_root' => '/var/www/socialcast',
    'app_root' =>  '/var/www/socialcast',
    'app_shared_root' => '/var/www/socialcast',
    'app_user' => 'socialcast',
    'ssl_pem_path' => '/etc/ssl/pem',
    'app_pem_file' => 'raa.pem',
    'cdn_disabled' => 'true',
    'solr_jvm_options' => '-server -d32 -Xmx500M -Xms64M', # Needs more granular configuration
    'rails_env' => 'production',
    'scheduler_env' => 'production',
    
    # Variables that don't directly apply to the appliance 
    :backup_s3_app_name => "appliance",
    :solr_newrelic_app_name => "appliance",
    :newrelic_app_name => 'appliance',
    :database_database => 'centurion_production',
    
    :aws_access_key_id => '',
    :aws_secret_access_key => '',
    :s3_bucket => '',
    :backup_s3_bucket => '',
    
    :cloudkick_oauth_key => '',
    :cloudkick_oauth_secret => ''
        
  }.each_pair do |key, value|
    cluster.variable key, value
  end
  
  cluster.node 'node1.fqdn', '10.11.11.321' do |node|
    
    node.role :db, :primary => true
    node.role :queue
    node.role :cron, :primary => true, :backup => true
    node.role :app
    node.role :worker
    node.role :munin, :node => true
    
    node.variable 'serverid', 1
    
  end
  
  cluster.node 'node2.fqdn', '10.11.11.123' do |node|
    
    node.role :web
    node.role :app
    node.role :puppet_master
    node.role :munin, :master => true, :node => true
    node.role :search
    
  end
end