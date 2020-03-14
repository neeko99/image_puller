class PullerFactory

  require 'strategies/flickr'

  def self.create(type)
    case type.downcase
    when 'flickr'
      Strategy::Flickr
    end
    # TODO:  add other strategies
  end
end

