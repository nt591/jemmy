module Jemmy
  class CLI < Thor
    include Thor::Actions

    module Thor::Actions
      def source_paths
        ['./templates']
      end
    end

    desc "jemmy GEM", "Creates a skeleton for creating a javascript rubygem"
    method_option :bin, :type => :boolean, :default => false, :aliases => '-b', :banner => "Generate a binary for your library."
    method_option :test, :type => :string, :default => nil, :aliases => '-t', :banner => "Generate test directory for your library."
    def jemmy(name)
      name = name.chomp("/") # remove trailing slash if present
      target = File.join(Dir.pwd, "#{name}-rails")
      constant_name = name.split('_').map{|p| p[0..0].upcase + p[1..-1] }.join
      constant_name = constant_name.split('-').map{|q| q[0..0].upcase + q[1..-1] }.join('::') if constant_name =~ /-/
      constant_array = constant_name.split('::')
      FileUtils.mkdir_p(File.join(target, 'lib', name))
      git_user_name = `git config user.name`.chomp
      git_user_email = `git config user.email`.chomp
      opts = {
        :name           => name,
        :constant_name  => constant_name,
        :constant_array => constant_array,
        :author         => git_user_name.empty? ? "TODO: Write your name" : git_user_name,
        :email          => git_user_email.empty? ? "TODO: Write your email address" : git_user_email
      }
      # def self.source_path
        # puts File.expand_path(__FILE__)
        # File.dirname(__FILE__)
        # ['./templates']
      # end
      
      template(File.join("newjem/Gemfile.tt"),               File.join(target, "Gemfile"),                opts)
      template(File.join("newjem/Rakefile.tt"),              File.join(target, "Rakefile"),               opts)
      template(File.join("newjem/LICENSE.txt.tt"),           File.join(target, "LICENSE.txt"),            opts)
      template(File.join("newjem/README.md.tt"),             File.join(target, "README.md"),              opts)
      template(File.join("newjem/gitignore.tt"),             File.join(target, ".gitignore"),             opts)
      template(File.join("newjem/newjem.gemspec.tt"),        File.join(target, "#{name}-rails.gemspec"),  opts)
      template(File.join("newjem/lib/newjem.rb.tt"),         File.join(target, "lib/#{name}-rails.rb"),   opts)
      template(File.join("newjem/lib/newjem/rails/version.rb.tt"), 
               File.join(target, "lib/#{name}/rails/version.rb"), opts)
      template(File.join("newjem/lib/newjem/rails/engine.rb.tt"),  
               File.join(target, "lib/#{name}/rails/engine.rb"),  opts)
      template(File.join("newjem/vendor/assets/javascripts/newjem.rb.tt"),  
               File.join(target, "vendor/assets/javascripts/#{name}.js"), opts)
      if options[:bin]
        template(File.join("newjem/bin/newjem.tt"),          File.join(target, 'bin', name),              opts)
      end

      case options[:test]
      when 'rspec'
        template(File.join("newjem/rspec.tt"),               File.join(target, ".rspec"),                 opts)
        template(File.join("newjem/spec/spec_helper.rb.tt"), File.join(target, "spec/spec_helper.rb"),    opts)
        template(File.join("newjem/spec/newjem_spec.rb.tt"), File.join(target, "spec/#{name}_spec.rb"),   opts)
      when 'minitest'
        template(File.join("newjem/test/minitest_helper.rb.tt"), File.join(target, "test/minitest_helper.rb"), opts)
        template(File.join("newjem/test/test_newjem.rb.tt"),     File.join(target, "test/test_#{name}.rb"),    opts)
      end
      # Bundler.ui.info "Initializating git repo in #{target}"
      Dir.chdir(target) { `git init`; `git add .` }
    end
  end
end