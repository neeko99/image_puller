Gem::Specification.new do |spec|
  spec.name          = 'image_puller'
  spec.version       =  '0.1.0'
  spec.authors       = ['Nick Longmore']
  spec.email         = ['neeko99@gmail.com']
  spec.summary       = 'Pulls all images from Flickr under photostreams '
  spec.description   = 'Image Puller'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  # spec.executables  << './ImagePuller/bin/image_puller.rb'
  spec.require_paths = ['lib']
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_dependency 'activesupport', '~> 5.2'
  spec.add_dependency 'dotenv-rails',  '~> 2.7'
  spec.add_dependency 'flickraw'
  spec.add_dependency 'ruby-progressbar', '~> 1.10'
end
