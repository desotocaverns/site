module Jekyll
  module Tags
    class Figure < BaseTag
      def render(context)
        super
        figure_tag
      end
    end
  end
end

Liquid::Template.register_tag('figure', Jekyll::Tags::Figure)
