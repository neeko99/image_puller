class ImagePuller
  require 'dotenv'
  require 'flickraw'
  require 'pry-byebug'
  require 'flickr/authenticator'
  require 'open-uri'
  require 'fileutils'
  require 'ruby-progressbar'
  require 'active_support/all'

  Dotenv.load

  MAX_RETRIES = 10

  def get
    return puts 'Missing env variables. Please review documentation' unless has_requirements?

    auth = Flickr::Authenticator.new
    @flickr = auth.flickr
    download_in_batches
  end

  private

  def download_in_batches
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

  def get_photo(id)
    # transform to json and then back to a hash so we can use hash methods
    photoset_details = JSON.parse(@flickr.photos.getAllContexts(photo_id: id).to_json)
    album_title = photoset_details.dig('set', 0, 'title') || 'misc'

    info = @flickr.photos.getInfo(photo_id: id)
    download(FlickRaw.url_o(info), album_title.parameterize)
  end

  def download(url, title)
    retry_count ||= 0
    open(url) do |image|
      filename = url.split('/')[-1]
      path = "#{ENV['OUTPUT_PATH']}/#{title}/#{filename}"

      FileUtils.mkdir_p(File.dirname(path))
      open(path, 'wb') { |file| file.write(image.read) }
    end
  rescue StandardError => e
    puts "cannot download #{url} error: #{e.message}" if retry_count.zero?

    retry_count += 1
    puts "Retry retry #{retry_count}/#{MAX_RETRIES}"
    retry unless retry_count == MAX_RETRIES
  end

  private

  def has_requirements?
    ENV['FLICKRAW_SHARED_SECRET'].present? && ENV['FLICKRAW_API_KEY'].present? && ENV['FLICKR_USER_ID'].present? && ENV['OUTPUT_PATH'].present?
  end
end

