require 'pry-byebug'
require 'kramdown'
module Jekyll
  module Tags
    class Card < Liquid::Block
      @@classname = 'card'

      def initialize(tag_name, markup, tokens)
        @markup = markup
        super
      end

      def process_markup
        @options = {}
        @markup.sub!(/(".+?)"/) { @options[:title] = $1; ''}

        @markup.split(' ').each do |arg|
          if arg.match(/^".+"/)
          elsif arg.match(/^\$/)
            @options[:price] = price arg
          elsif arg.match(/\.(jpg|jpeg|png|gif)/)
            @options[:figure] = figure arg
          elsif arg.match(/vimeo/)
            @options[:video] = embed_video arg
          elsif arg.match(/:\/\//) || arg.match(/^\//)
            @options[:url] = arg
          end
        end
      end

      def prerender(content)
        # Ensure that markdown titles are separated by new lines
        content.gsub(/^(#.+$)/) { "\n#{$1}" }
      end

      def figure(src)
        %Q{<figure class="card-figure"><img src="#{image_path src}"></figure>}
      end

      def price(amount)
        %Q{<div class="price">#{amount}</div>}
      end

      def image_path(path)
        File.join @config["baseurl"], @config["image_dir"], path
      end

      def buttonify(content)
        content.sub!(/<p>(<a.+)<\/p>$/) do
          %Q{<div class="card-footer">#{$1.sub(/<a /, '<a class="card-button" ')}</div>}
        end
      end

      def html(content)
        buttonify content

        tag = @options[:url].nil? ? 'div' : %Q{a href="#{@options[:url]}"}
        endtag = @options[:url].nil? ? 'div' : 'a'

        output = %Q{<#{tag} class="card">
  <div class="card-header">
    <h1 class='card-title'>#{@options[:title]}</h1>
    #{@options[:price]}
    #{@options[:figure]}
  </div>
  <div class="card-content">#{content}</div>
</#{endtag}>}
      end

      def render(context)
        @site = context.registers[:site]
        @config = @site.config

        process_markup

        content = prerender(super)
        html Kramdown::Document.new(content).to_html
      end
    end
  end
end


Liquid::Template.register_tag('card', Jekyll::Tags::Card)
