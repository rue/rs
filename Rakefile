begin
  require "rubygems"
    require "jeweler"

  namespace :jeweler do
    Jeweler::Tasks.new do |gem|
      gem.name        = "rs"

      gem.version     = `git log --pretty=oneline | wc -l`.strip


      gem.summary     = "Object-oriented shell in full Ruby environment."
      gem.description = <<-END.gsub /\s+/, " "

                        rs is the result of my object-oriented shell musings,
                        experiments and implementations. Its focus is above
                        all on simplicity and the best possible implementation
                        of modern shell usage and needs.

                        END

      gem.email       = "rs@projects.kittensoft.org"
      gem.homepage    = "http://github.com/rue/rs"
      gem.authors     = ["Eero Saynatkari"]


      gem.add_development_dependency  "rspec",        ">= 1.3.0"

      gem.post_install_message = <<-END

      =======================================

      /path/to/cwd rs> _

      =======================================

      END
    end

    Jeweler::GemcutterTasks.new
  end

rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end


# Main tasks

desc "Generate Gem and push it."
task :release_gem => %w[jeweler:gemcutter:release]

