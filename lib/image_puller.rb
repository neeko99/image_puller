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
      return unless has_settings_file?(file_path)

      system('clear') || system('cls')

      puts '*** Please select puller ***'
      puts '-' * 20
      SUPPORTED_PULLERS.each_with_index do |puller, i|
        puts "#{i}: #{puller}"
      end

      selection = gets.strip
      raise StupidUserError unless selection.match?(/[0-9]/) && puller = SUPPORTED_PULLERS[selection.to_i]

      factory = PullerFactory.create(puller)
      factory.exec
    rescue StupidUserError
      puts "Sorry!! Unable find selected \n press any key to continue"
      gets
      retry
    end

    private

    def has_settings_file?(settings_file_path)
      unless settings_file_path && File.exist?(settings_file_path)
        puts 'Invalid settings file'
        return false
      end

      settings = JSON.parse(File.read(settings_file_path))
      settings.each { |key, value| ENV[key] = value }
      true
    end
  end
end
