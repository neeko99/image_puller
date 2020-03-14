module Flickr
  class Downloader

    def initialize(flickr)
      @flickr = flickr
    end

    MAX_RETRIES = 10

    def download
      page = 0
      per_page = 100

      loop do
        page += 1

        begin
          retry_count ||= 0
          images = @flickr.people.getPhotos(user_id: ENV['FLICKR_USER_ID'], page: page, per_page: per_page)

          pb = ProgressBar.create(title: "Images Page #{page}")
          images.each do |photoset|
            get_photo(photoset['id'])
            pb.increment
          end
        rescue StandardError => e
          puts "Failed on #{page} exception: #{e.message}" if retry_count.zero?

          retry_count += 1
          sleep(1.minute)
          puts "Retry retry #{retry_count}/#{MAX_RETRIES}"
          retry unless retry_count == MAX_RETRIES
        end

        break if images.size < per_page
      end
    end

    private

    def get_photo(id)
      # transform to json and then back to a hash so we can use hash methods
      photoset_details = JSON.parse(@flickr.photos.getAllContexts(photo_id: id).to_json)
      album_title = photoset_details.dig('set', 0, 'title') || 'misc'

      info = @flickr.photos.getInfo(photo_id: id)

      filename = "#{info['title']}.#{info['originalformat']}"

      case info['media']
      when 'photo'
        return unless ENV['PHOTO'] == 'true'

        url = FlickRaw.url_o(info)
      when 'video'
        return unless ENV['VIDEO'] == 'true'
        return unless original_video = @flickr.photos.getSizes(photo_id: id).detect{ |size| size['label'] == 'Video Original' }

        url = original_video['source']
      end

      return unless url

      url_download(url, album_title, filename)

    end

    def url_download(url, album_title, filename)
      retry_count ||= 0
      open(url) do |image|
        path = "#{ENV['OUTPUT_PATH']}/#{album_title}/#{filename}"

        FileUtils.mkdir_p(File.dirname(path))
        open(path, 'wb') { |file| file.write(image.read) }
      end
    rescue StandardError => e
      puts "cannot download #{url} error: #{e.message}" if retry_count.zero?

      retry_count += 1
      puts "Retry retry #{retry_count}/#{MAX_RETRIES}"
      retry unless retry_count == MAX_RETRIES
    end
  end
end

