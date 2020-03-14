class StupidUserError < StandardError
end

class ImagePuller
  require 'dotenv'
  require 'pry-byebug'
  require 'open-uri'
  require 'fileutils'
  require 'ruby-progressbar'
  require 'active_support/all'
  require 'puller_factory'

  Dotenv.load

  SUPPORTED_PULLERS = ['flickr']


  def pull
    begin
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
  end
end
