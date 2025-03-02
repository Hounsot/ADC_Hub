module UrlHelper
  def simplified_domain(url)
    return nil if url.blank?

    uri = URI.parse(url)
    host = uri.host.downcase
    # Remove www. if present
    host = host.start_with?("www.") ? host[4..-1] : host
    host
  rescue URI::InvalidURIError
    nil
  end

  def website_type(url)
    return "default" if url.blank?

    domain = simplified_domain(url)
    return "default" if domain.nil?

    case domain
    when "behance.net"
      "behance"
    when "youtube.com", "youtu.be"
      "youtube"
    when "instagram.com"
      "instagram"
    when "twitter.com"
      "twitter"
    when "music.yandex.ru"
      "yandexmusic"
    when "vimeo.com"
      "vimeo"
    when "t.me"
      "telegram"
    when "open.spotify.com"
      "spotify"
    when "dprofile.ru"
      "dprofile"
    when "rutube.ru"
      "rutube"
    when "vk.com"
      "vk"
    when "wikipedia.org"
      "wikipedia"
    else
      "default"
    end
  end
end
