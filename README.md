# ImagePuller

## *** Currently only supports Flickr ***
Gem designed to pull all images/videos from hosting providers.  

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'image_puller'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install image_puller

## Usage

# Flickr 
- Require API key and Secret via https://www.flickr.com/services/apps/create
- Add settings into env variables (see Settings)

Run image_puller and follow onscreen prompts

## Settings

# Flickr Specific Settings

- ENV['FLICKRAW_API_KEY'] = Flickr API
- ENV['FLICKRAW_SHARED_SECRET'] = Flickr secret
- ENV['OUTPUT_PATH'] = local path to export to
- ENV['FLICKR_USER_ID'] = https://www.flickr.com/services/api/explore/?method=flickr.people.getInfo under 'Your User ID'
- ENV['PHOTO'] = ('true'/'false')
- ENV['VIDEO'] = ('true'/'false')

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/neeko99/image_puller.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
