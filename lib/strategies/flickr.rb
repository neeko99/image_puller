module Strategy
  class Flickr
    require 'flickraw'
    require 'flickr/authenticator'
    require 'flickr/downloader'


    class << self

      def exec
        return puts 'Missing Requirements for Flickr Download please see documentation' unless has_requirements?

        auth = ::Flickr::Authenticator.new
        downloader = ::Flickr::Downloader.new(auth.flickr)

        downloader.download
      end

      private

      def has_requirements?
        ENV['FLICKRAW_SHARED_SECRET'] && ENV['FLICKRAW_API_KEY'] && ENV['FLICKR_USER_ID'] && ENV['OUTPUT_PATH']
      end
    end
  end
end
