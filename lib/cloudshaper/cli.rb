require 'thor'
require 'cloudshaper'

module Cloudshaper
  class CLI < Thor
    class_option "template_dir", "type" => "string", "default" => Dir.pwd

    desc "list", "List all available stacks"
    def list
    end

    desc "show NAME", "Show details about a stack by name"
    def show(name)
    end

    desc "plan NAME", "Show pending changes for a stack"
    def plan(name)
    end

    desc "apply NAME", "Apply all pending stack changes"
    def apply(name)
      # TODO
    end

    desc "destroy NAME", "Destroy a stack"
    def destroy(name)
      # TODO
    end

    desc "pull NAME", "Pull stack state from remote location"
    def pull(name)
    end

    desc "push NAME", "Push stack state from remote location"
    def push(name)
    end

    desc "remote_config NAME", "Sets up remote config for a stack"
    def remote_config(name)
    end

    desc "init", "Initialize stacks.yml if it does not exist"
    def init
      Cloudshaper::Stacks.init
    end

    desc "uuid", "Generate a UUID for your stacks, so they don't clobber each other"
    def uuid
      puts SecureRandom.uuid
    end

    desc "version", "Prints the version of cloudshaper"
    def version
      puts Cloudshaper::VERSION
    end
  end
end
