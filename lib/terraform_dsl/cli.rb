require 'thor'
require 'terraform_dsl'

module Terraform
  class CLI < Thor
    class_option :template_dir, :type => :string, :default => Dir.pwd

    desc :hello, "Say hello"
    def hello
      puts "Hello world"
    end
  end
end
