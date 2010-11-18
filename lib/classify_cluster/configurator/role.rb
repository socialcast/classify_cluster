module ClassifyCluster
  module Configurator
    class Role
      attr_reader :type, :options, :node, :variables
      def initialize(node, type, options={}, &block)
        @type = type
        @options = options.symbolize_keys
        @node = node
        @variables = {}
        block.call(self) if block_given?
        self.send("after_#{@type}_role_assignment".to_sym)
      end
      def type(value = nil)
        return @type unless value
        @type = value
      end
      def options(value = nil)
        return @options unless value
        @options = value
      end
      def variable(name, value)
        @variables[name] = value
        @node.variable name, value
      end
      private
      def add_klass_from_role
        case @type.to_s
        when "db"
          @node.klass "databaseserver::onpremise" if @options.has_key?(:primary)
          @node.klass "databasereplicationserver::onpremise" if @options.has_key?(:backup)
        when "puppet_master"
          @node.klass "puppetmaster::onpremise"
        when "munin"
          @node.klass "munin::master::onpremise" if @options.has_key?(:master)
          @node.klass "munin::node::onpremise" if @options.has_key?(:node)
        when "cache"
          @node.klass "memcached"
        when "queue"
          @node.klass "#{@type.to_s}server::onpremise"
        when "app"
          @node.klass "#{@type.to_s}server::onpremise"
        when "worker"
          @node.klass "#{@type.to_s}server::onpremise"
        when "web"
          @node.klass "#{@type.to_s}server::onpremise"
        when "push"
          @node.klass "#{@type.to_s}server::onpremise"
        when "search"
          @node.klass "#{@type.to_s}server::onpremise"
        when "file"
          @node.klass "#{@type.to_s}server::onpremise"
        end
      end
      def add_variable_from_role
        case @type.to_s
        when 'app'
          @node.cluster.variables['app_servers'] ||= []
          @node.cluster.variables['app_servers'] << @node.private_ip
        when 'db'
          @node.cluster.variable('database_host', @node.private_ip) if @options.has_key?(:primary)
        when 'queue'
          @node.cluster.variable 'queue_host', @node.private_ip
        when 'push'
          @node.cluster.variable 'blow_server', @node.private_ip
        when 'search'
          @node.cluster.variable 'solr_host', @node.private_ip
        when 'munin'
          @node.cluster.variable('munin_master', @node.private_ip) if @options.has_key?(:master)
        when 'file'
          @node.cluster.variables['fileserver_hosts'] ||= []
          @node.cluster.variables['fileserver_hosts'] << @node.private_ip
        end
      end
      def method_missing(method_name, *args)
        add_klass_from_role
        add_variable_from_role
      end
    end
  end
end