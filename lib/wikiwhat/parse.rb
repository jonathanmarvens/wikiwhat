module Parse

  class Results
    def initialize
      @result = nil
    end

    def pull_from_hash(hash, key)
      @hash = hash
      @key = key

      if @hash.include?(@key)
        @result = @hash[@key]
      else
        @hash.each_pair do |k, v|
          if v.class == Hash
            pull_from_hash(v, @key)
          end
        end
      end
      @result
    end
  end

  # Extract portions of text from Wiki article
  class Text < Results
    attr_reader :request
    def initialize(request, prop='extract')
      @request = self.pull_from_hash(request, prop)
      if @request.class == Array
        @request = self.pull_from_hash(@request[0], "*")
      end
    end

    # Returns the requested number of paragraphs of a Wiki article
    #
    # quantity - the Number of paragraphs to be returned starting from the top
    #            of the article. Defaults is to get the first paragraph.
    #
    def paragraph(quantity)
      # Break the article into individual paragraphs and store in an array.
      start = request.split("</p>")

      # Re-add the closing paragraph HTML tags.
      start.each do |string|
        string << "</p>"
      end

      # Check to make sure the quantity being requested is not more paragraphs
      # than exist.
      #
      # Return the correct number of paragraphs assigned to new_arr
      if start.length <= quantity
        quantity = quantity - 1
        new_arr = start[0..quantity]
      else
        new_arr = start
      end
    end

    # Removes HTML tags from a String
    #
    # string - a String that contains HTML tags.
    #
    # Returns the string without HTML tags.
    def only_text(string)
      no_html_tags = string.gsub(/<\/?.*?>/,'')
    end

    def wikitext_sections
    end

    # Return the image from the sidebar, if one exists
    def sidebar_image
      @sidebar_image = content_split(0)[/(?<= image = )\S*/].chomp
    end

    # Return all refrences as an array
    def refs
      @content = content_split(1, 2)
    
      #add all references to an array. still in wiki markup
      @refs = @content.scan(/<ref>(.*?)<\/ref>/)
     @refs

    end

    # Return all paragraphs under a given heading
    #
    # header = the name of the header as a String
    # paras  = the number of paragraphs
    def find_header(header)
      # Find the requested header
      start = @request.index(header)
      # Find next instance of the tag.
      end_first_tag = start + @request[start..-1].index("h2") + 3
      # Find
      start_next_tag = @request[end_first_tag..-1].index("h2") +
        end_first_tag - 2
      # Select substring of requested text.
      section =  @request[end_first_tag..start_next_tag]
    end

    # splits the content into side bar and everything else. 
    # this method is for Parsing methods that use the raw markup from the revisions call.
    # specify start as 0 for sidebar content, for everything else specify 1 ..2
    # TODO:split the content from the catagory info
    def content_split(start, finish=nil)
      @content = @request.split("'''")
      if finish == nil
        return @content[start]
      else
        return @content[start..finish].join
      end
    end


    # Returns user-defined number of words before and/or
    # a user-defined search term.
    def search(term, words, options={})
    end
  end

  class Media < Results
    def initialize
    end

    def list_images
      # Call API for initial list of images
      initial_list = JSON.parse(RestClient.get "http://en.wikipedia.org/w/api.php?action=query&generator=images&titles=Albert%20Einstein&format=json")
      isolated_list = pull_from_hash(initial_list, "pages")

      # Parse JSON object for list of image titles
      image_title_array = []
      isolated_list.each do |key, value|
        image_title_array << value["title"]
      end

      # Make API call for individual image links
      image_url_call_array = []
      image_title_array.each do |title|
        title = URI::encode(title)
        image_url_call_array << JSON.parse(RestClient.get "http://en.wikipedia.org/w/api.php?action=query&titles=#{title}&prop=imageinfo&iiprop=url&format=json")
      end

      # Pull array containing URL out from JSON object
      almost_url = []
      image_url_call_array.each do |object|
        almost_url << pull_from_hash(object, "imageinfo")
      end

      # Pull each URL and palce in an array
      url_array = []
      almost_url.each do |array|
        url_array << array[0]["url"]
      end

      return { urls: url_array, titles: image_title_array }
    end
  end
end
