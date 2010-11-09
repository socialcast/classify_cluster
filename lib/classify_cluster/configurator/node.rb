module ClassifyCluster
  module Configurator
    class Node
      ROLE_2_KLASS_MAP = {
        'db' => { 'primary' => 'databaseserver::onpremise', 'backup' => 'databasereplicationserver::onpremise'},
        'queue' => 'queueserver::onpremise',
        'app' => 'appserver::onpremise',
        'worker' => 'workerserver::onpremise',
        'web' => 'webserver::onpremise',
        'puppet_master' => 'puppetmaster::onpremise',
        'munin' => { 'master' => 'munin::master::onpremise', 'node' => 'munin::node::onpremise' },
        'push' => 'pushserver::onpremise',
        'cache' => 'memcached',
        'search' => 'searchserver::onpremise'
      }
      attr_reader :fqdn, :variables, :resources, :classes, :private_ip, :public_ip, :roles, :default
      def initialize(*args, &block)
        @variables = {}
        @resources = []
        @classes = []
        @roles = []
        @fqdn = (args.first.to_s == 'default' ? '' : args.first)
        @private_ip = (args[1].to_s == 'default' ? '' : args[1])
        @default = args.first.to_s == 'default'
        returned = block.call(self)
        @roles.each do |role|
          if ROLE_2_KLASS_MAP.has_key?(role.type)
            if role.options.size > 0
              role.options.each_pair do |key, value|
                @classes << ROLE_2_KLASS_MAP[role.type.to_s][key.to_s]
              end
            else
              @classes << ROLE_2_KLASS_MAP[role.type]
            end
          end
        end
      end
      def default?
        return @default
      end
      def fqdn(value=nil)
        return @fqdn unless value
        @fqdn = value
      end
      def private_ip(value = nil)
        return @private_ip unless value
        @private_ip = value
      end
      def public_ip(value = nil)
        return (@public_ip || @private_ip) unless value
        @public_ip = value
      end
      def role(type, options={})
        @roles << ClassifyCluster::Configurator::Role.new(type, options)
      end
      def variable(name, value)
        @variables[name] = value
      end
      def resource(&block)
        @resources << ClassifyCluster::Configurator::Resource.new(&block)
      end
      def klass(name)
        @classes << name
      end
    end
  end
end