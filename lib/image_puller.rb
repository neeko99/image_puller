class ImagePuller
  require 'dotenv'
  require 'flickraw'
  require 'pry-byebug'
  require 'flickr/authenticator'
  require 'open-uri'
  Dotenv.load

  def get
    auth = Flickr::Authenticator.new
    @flickr = auth.flickr
    download_in_batches
  end

  private

  def download_in_batches
    page = 0
    loop do
      page += 1
      photosets = @flickr.photosets.getList(page: page)
      get_photo_set_images(photosets.map { |photoset| photoset['id'] })

      break if photosets.size <= 500
    end
  end

  def get_photo_set_images(photoset_ids)
    photoset_ids.each do |set|
      page = 0
      loop do
        page += 1
        photos = @flickr.photosets.getPhotos(photoset_id: set, page: page)['photo']

        get_photos(photos.map { |photo| photo['id'] })

        break if photos.count <= 500
      end
    end
  end

  def get_photos(ids)
    ids.each do |id|
      info = @flickr.photos.getInfo(photo_id: id)
      download(FlickRaw.url_o(info))
    end
  end

  def download(url)
    begin
      open(url) do |image|
        filename = url.split('/')[-1]
        File.open("/Users/nicklongmore/Pictures/flickr_backup/#{filename}", 'wb') do |file|
          file.write(image.read)
        end
      end
    rescue StandardError => e
      puts e.message
      puts "cannot download #{url}"
    end
  end
end

