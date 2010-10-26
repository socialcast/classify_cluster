cluster_common = %w{ ntp conary sysstat }
onpremise_common = %w{ sudo cron monit::disabled }

cluster :"appliance-cluster" do |cluster|
  common_classes = cluster_common + onpremise_common
  common_variables = {}
  common_resources = {}
  cluster.node :mylittlewebserver do |node|
    common_classes.each do |common_class|
      node.klass common_class
    end
    common_variables.each_pair do |key, value|
      node.variable key, value
    end
    common_resources.each_pair do |key, value|
      node.resource do |resource|
        resource.type value[:type]
        resource.name key
        resource.options value[:options]
      end
    end
    node.klass "webserver"
    node.variable :appservers, ['123.456.28.1']
    node.role do |role|
      role.type :web
    end
  end
end
