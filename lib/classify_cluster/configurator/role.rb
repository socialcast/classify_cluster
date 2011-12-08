module ClassifyCluster
  module Configurator
    ROLES = [
      'file',
      'scheduler',
      'app',
      'web',
      'push',
      'puppet_master',
      {'munin' => ['master', 'node']},
      'cache',
      {'db' => ['primary', 'backup']},
      'queue',
      {'cron' => ['primary', 'backup']},
      'search',
      'worker',
      'sso'
    ]
    class Role
      begin
        require 'active_support/hash_with_indifferent_access'
        include ActiveSupport
      rescue LoadError
      end
      
      attr_reader :type, :options, :node, :variables
      def initialize(node, type, options={}, &block)
        @type = type
        @options = HashWithIndifferentAccess.new(options)
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
          @node.klass "databaseserver" if @options.has_key?(:primary)
          @node.klass "databasereplicationserver" if @options.has_key?(:backup)
        when "puppet_master"
          @node.klass "puppetmaster"
        when "munin"
          @node.klass "munin::master" if @options.has_key?(:master)
          @node.klass "munin::node" if @options.has_key?(:node)
        when "queue"
          @node.klass "#{@type.to_s}server"
        when "app"
          @node.klass "#{@type.to_s}server"
        when "worker"
          @node.klass "#{@type.to_s}server"
        when "web"
          @node.klass "#{@type.to_s}server"
        when "push"
          @node.klass "#{@type.to_s}server"
        when "search"
          @node.klass "#{@type.to_s}server"
        when "file"
          @node.klass "#{@type.to_s}server"
        when "cache"
          @node.klass "#{@type.to_s}server"
        when "scheduler"
          @node.klass "#{@type.to_s}server"
        when "sso"
          @node.klass "#{@type.to_s}server"
        end
      end
      def add_variable_from_role
        case @type.to_s
        when 'app'
          @node.cluster.variables['app_hosts'] ||= []
          @node.cluster.variables['app_hosts'] << @node.private_ip
        when 'db'
          @node.cluster.variable('database_host', @node.private_ip) if @options.has_key?(:primary)
        when 'queue'
          @node.cluster.variable 'queue_host', @node.private_ip
        when 'push'
          @node.cluster.variable 'blow_host', @node.private_ip
        when 'search'
          @node.cluster.variable 'elasticsearch_host', "#{@node.private_ip}:9200"      
        when 'munin'
          @node.cluster.variable('munin_master', @node.private_ip) if @options.has_key?(:master)
        when 'file'
          @node.cluster.variables['fileserver_hosts'] ||= []
          @node.cluster.variables['fileserver_hosts'] << @node.private_ip
        when 'cache'
          @node.cluster.variable 'cache_host', @node.private_ip
        when 'sso'
          @node.cluster.variable 'ping_federate_host', @node.private_ip
        end
      end
      def method_missing(method_name, *args)
        add_klass_from_role
        add_variable_from_role
      end
    end
  end
end