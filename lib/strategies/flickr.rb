module Strategy
  class Flickr
    require 'flickraw'
    require 'flickr/authenticator'
    require 'flickr/downloader'

    class << self
      def exec
        return puts 'Missing Requirements for Flickr Download please see documentation' unless has_requirements?

        auth = ::Flickr::Authenticator.authenticate
        downloader = ::Flickr::Downloader.new(auth)

        downloader.download
      end

      private

      def has_requirements?
        ENV['FLICKR_SHARED_SECRET'] && ENV['FLICKR_API_KEY'] && ENV['FLICKR_USER_ID'] && ENV['OUTPUT_PATH']
      end
    end
  end
end
