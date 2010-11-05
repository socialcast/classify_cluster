cluster_common = %w{ ntp conary sysstat }
onpremise_common = %w{ sudo cron monit::disabled }

cluster :"appliance-cluster" do |cluster|
  (cluster_common + onpremise_common).each do |common_class|
    cluster.klass common_class
  end
  {}.each_pair do |key, value|
    cluster.variable key, value
  end
  {}.each_pair do |key, value|
    cluster.resource do |resource|
      resource.type value[:type]
      resource.name key
      resource.options value[:options]
    end
  end
  cluster.node :"example.com" do |node|
    node.klass "webserver"
    node.variable :appservers, ['123.456.28.1']
    node.role do |role|
      role.type :web
    end
  end
end
