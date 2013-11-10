require 'open-uri'
require 'rest_client'
require 'json'

module Wikiwhat
  class Call
    # Make a string that is the URL for the API call for text-based requests.
    # Call the API and parse the returning JSON object.
    def self.call_api(title, options={})
      title = URI::encode(title)
      options[:prop] ? prop = "&prop=#{options[:prop]}" : ''
      options[:rvprop] ? rvprop = "&rvprop=content" : rvprop = ''
      options[:img_list] ? img_list = "&generator=images" : img_list = ''
      options[:iiprop] ? iiprop = "&iiprop=url" : iiprop = ''
      options[:geosearch] ? geosearch = "&list=geosearch&gsradius=10000&gscoord=#{options[:coordinates]}"

      list=geosearch&gsradius=10000&gscoord=37.786971|-122.399677

      JSON.parse(RestClient.get "http://en.wikipedia.org/w/api.php?action=query#{prop}&titles=#{title}&format=json&redirects#{img_list}#{rvprop}#{iiprop}#{geosearch}")
    end
  end
end
