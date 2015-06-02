require 'json'
require 'fileutils'

require_relative 'stack_templates.rb'
require_relative 'secrets.rb'
require_relative 'resource.rb'
require_relative 'provider.rb'
require_relative 'variable.rb'

module Terraform
  class StackTemplate
    class VariableDefinition
      attr_reader :name, :default

      def initialize(name, default: nil)
        @name, @default = name, default
      end

      def as_json(_options = {})
        {
          name: @name,
          default: @default
        }
      end
    end

    class << self
      attr_accessor :stack_elements, :variable_definitions

      def register_resource(resource_type, name, &block)
        @stack_elements[:resource] ||= {}
        @stack_elements[:resource][resource_type.to_sym] ||= {}
        @stack_elements[:resource][resource_type.to_sym][name.to_sym] = Terraform::Resource.new(name, resource_type, &block).fields
      end

      def register_variable(name, &block)
        new_variable = Terraform::Variable.new(&block).fields
        @stack_elements[:variable][name.to_sym] = new_variable
        @variable_definitions[name.to_sym] = VariableDefinition.new(name, default: new_variable[:default])
      end

      def register_provider(name, &block)
        provider = Terraform::Provider.new(&block)
        case name
        when 'aws'
          provider.fields[:access_key] = Secrets[:aws][:access_key_id]
          provider.fields[:secret_key] = Secrets[:aws][:secret_access_key]
        end
        @stack_elements[:provider][name.to_sym] = provider.fields
      end

      def reset!
        @stack_elements = { resource: {}, provider: {}, variable: {} }
        @variable_definitions = {}
      end

      def inherited(subclass)
        StackTemplates.register(subclass)
        subclass.reset!
        super
      end

      def generate
        JSON.pretty_generate(@stack_elements)
      end

      alias_method :resource, :register_resource
      alias_method :variable, :register_variable
      alias_method :provider, :register_provider
    end

    reset!

    attr_reader :stack

    def initialize(stack, _stack_dir)
      @stack = stack
      @stack_dir = data_dir
      FileUtils.mkdir_p(@stack_dir)
    end

    def env
      @stack.stack_variables.each { |v| "TF_VAR_#{v.key}=#{v.value}" }
    end

    protected

    def variables
      @variables ||= begin
        hash = {}

        variable_definitions.each do |name, definition|
          hash[name] = definition.default
        end

        stack.stack_variables.each do |sv|
          hash[sv.key.to_sym] = sv.value
        end

        hash
      end
    end

    def variable_definitions
      self.class.variable_definitions
    end

    def stack_elements
      self.class.stack_elements
    end
  end
end
