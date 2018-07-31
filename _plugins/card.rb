require 'pry-byebug'
require 'kramdown'
module Jekyll
  module Tags
    class Card < BaseBlock

      def figure
        figure_tag('card-figure') if @options[:image]
      end

      def price
        %Q{<div class="price">#{@options[:price]}</div>} if @options[:price]
      end

      def buttonize(content)
        content.gsub(/button:(<a.+?\/a>)/) do
          %Q{#{$1.sub(/<a /, '<a class="card-button" ')}}
        end
      end

      def footerize(content)
        if content.match(/<hr\s*\/?/)
          parts = content.split(/<hr\s*\/?>/)
          @footer = %Q{<div class="card-footer">#{parts.pop}</div>}
          content = parts.join
        end

        content
      end

      def html(content)
        content = buttonize content
        content = footerize content

        tag = @options[:url].nil? ? 'div' : %Q{a href="#{@options[:url]}"}
        endtag = @options[:url].nil? ? 'div' : 'a'

        output = %Q{<#{tag} class="card #{@options[:class].join(' ')}">
  #{figure}
  <div class="card-header">
    <h4 class='card-heading'>#{@options[:title]}</h4>
    #{price}
  </div>
  <div class="card-content">#{content}</div>
  #{@footer}
</#{endtag}>}
      end

      def render(context)
        html markdown(super)
      end
    end
  end
end

Liquid::Template.register_tag('card', Jekyll::Tags::Card)
