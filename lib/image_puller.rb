class StupidUserError < StandardError
end

class ImagePuller
  require 'pry-byebug'
  require 'open-uri'
  require 'fileutils'
  require 'ruby-progressbar'
  require 'active_support/all'
  require 'puller_factory'

  class << self

    SUPPORTED_PULLERS = ['flickr'].freeze

    def pull(file_path = nil)
      return unless valid_settings_file?(file_path) && valid_type

      factory = PullerFactory.create(ENV['PULLER_TYPE'])
      factory.exec
    end

    private

    def valid_settings_file?(settings_file_path)
      unless settings_file_path && File.exist?(settings_file_path)
        puts 'Invalid settings file'
        return false
      end

      settings = JSON.parse(File.read(settings_file_path))
      settings.each { |key, value| ENV[key] = value.to_s }

      true
    end

    def valid_type
      unless SUPPORTED_PULLERS.include? ENV['PULLER_TYPE']
        puts 'Invalid Type'
        return false
      end

      true
    end
  end
end
