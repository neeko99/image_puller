module Flickr
  class Authenticator

    def flickr
      return @flickr if @flickr

      @flickr = get_tokens
    end

    def get_tokens
      flickr = FlickRaw::Flickr.new(api_key: ENV['FLICKRAW_API_KEY'], shared_secret: ENV['FLICKRAW_SHARED_SECRET'])
      auth_key = JSON.parse(File.read('authkey.json'))

      flickr.access_token = auth_key['access_token']
      flickr.access_secret = auth_key['secret']

      begin
        flickr.test.login
        flickr
      rescue  FlickRaw::FailedResponse => e
        authenticate
        # retry
        get_tokens
      end
    end

    def authenticate
      token = flickr.get_request_token
      auth_url = flickr.get_authorize_url(token['oauth_token'], :perms => 'delete')

      puts "Open this url in your browser to complete the authentication process : #{auth_url}"
      puts "Copy here the number given when you complete the process."
      verify = gets.strip

      begin
        flickr.get_access_token(token['oauth_token'], token['oauth_token_secret'], verify)
        login = flickr.test.login
        puts "You are now authenticated as #{login.username} with token #{flickr.access_token} and secret #{flickr.access_secret}"
        File.write('authkey.json', { access_token: flickr.access_token, secret: flickr.access_secret }.to_json)
        flickr
      rescue FlickRaw::FailedResponse => e
        puts "Authentication failed : #{e.msg}"
      end
    end
  end
end
