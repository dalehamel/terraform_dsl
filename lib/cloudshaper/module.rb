require 'cloudshaper/stack_element'
require 'cloudshaper/stack_modules'
require 'cloudshaper/stack_module'
require 'cloudshaper/stacks'

module Cloudshaper
  # Supports terraform 'modules'. In our case, we call them submodules because
  # Module is a ruby keyword. We also support directly referencing other ruby-defined modules.
  class Module < StackElement
    def initialize(parent_module, &block)
      super(parent_module, &block)

      if StackModules.has? @fields[:source].to_s
        mod = StackModules.get @fields[:source].to_s
        module_path = File.join(Stacks.dir, parent_module.id, mod.name)
        FileUtils.mkdir_p(module_path)
        @fields[:source] = File.expand_path(module_path)
        @fields[:cloudshaper_stack_id] = var(:cloudshaper_stack_id)

        file_path = File.join(module_path, 'stack_module.tf.json')
        build_submodule(file_path, mod)
      end
    end

    def build_submodule(file_path, child_module)
      child_module.build
      File.open(file_path, 'w') { |f| f.write(child_module.generate) }
    end
  end
end
