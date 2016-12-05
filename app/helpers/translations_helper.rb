module TranslationsHelper
  def purge_cache(uri)
    request = Typhoeus::Request.new(
        "http://gist.mejelly.com:8000#{uri}",
        method: :purge,
    )
    request.run
  end
end
