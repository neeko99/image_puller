module Flickr
  class Downloader

    def initialize(flickr)
      @flickr = flickr
    end

    MAX_RETRIES = 10
    PER_PAGE = 500


    def download
      page = ENV['FLICKR_STARTING_PAGE'].to_i

      loop do
        page += 1

        begin
          retry_count ||= 0
          images = @flickr.people.getPhotos(user_id: ENV['FLICKR_USER_ID'], page: page, per_page: PER_PAGE)

          pb = ProgressBar.create(title: "Page #{page}/#{images['pages']}", total: PER_PAGE)
          images.each { |photoset| get_photo(photoset['id']); pb.increment }
        rescue StandardError => e
          retry_count += 1
          sleep(30.seconds)
          retry unless retry_count == MAX_RETRIES

          puts "Failure on page #{page}"
        end

        break if images.nil? || images.size < PER_PAGE
      end
    end

    private

    def get_photo(id)
      info = @flickr.photos.getInfo(photo_id: id)

      case info['media']
      when 'photo'
        return unless ENV['PHOTO'] == 'true'

        url = FlickRaw.url_o(info)
        filename = url.split('/')[-1]
        #TODO: add support for video
      end

      return unless url

      url_download(url, path(album_title(id), filename))
    end

    def url_download(url, path)
      retry_count ||= 0

      open(url) do |image|
        FileUtils.mkdir_p(File.dirname(path))
        open(path, 'wb') { |file| file.write(image.read) }
      end
    rescue StandardError => e
      retry_count += 1
      retry unless retry_count == MAX_RETRIES

      puts "cannot download #{url} to #{path} error: #{e.message}"
    end

    def album_title(id)
      # transform to json and then back to a hash so we can use hash methods
      photoset_details = JSON.parse(@flickr.photos.getAllContexts(photo_id: id).to_json)
      photoset_details.dig('set', 0, 'title') || 'misc'
    end

    def path(album_title, filename)
      "#{ENV['OUTPUT_PATH']}/#{album_title}/#{filename}"
    end
  end
end

