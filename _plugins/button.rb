module Jekyll
  module Tags
    class Button < BaseTag
      def render(context)
        super
      end
    end
  end
end

Liquid::Template.register_tag('button', Jekyll::Tags::Button)

