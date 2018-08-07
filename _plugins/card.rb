require 'pry-byebug'
require 'kramdown'
module Jekyll
  module Tags
    class Card < BaseBlock

      def figure
        figure_tag(@options["image"], class: 'card-figure') if @options["image"]
      end

      def price
        content_tag(:div, @options["price"], class: 'price') if @options["price"]
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
        card { buttonize content }
      end

      def render(context)
        @options["class"].push "card"
        html markdown(super)
      end
    end
  end
end

Liquid::Template.register_tag('card', Jekyll::Tags::Card)
