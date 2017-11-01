module Http
  class PostService
    include Serviceable

    def call(content, url)
      uri = URI(url)

      uri.path = '/' if uri.path.empty?

      https = Net::HTTP.new(uri.host, uri.port)
      response = https.post(uri.path, content.to_query)

      response.code == '200'
    rescue Errno::ECONNREFUSED
      false
    end
  end
end
