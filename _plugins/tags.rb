module Jekyll
  module Tags
    class Figure < BaseTag
      def render(context)
        super
        figure_tag
      end
    end
    
    class LinkTo < BaseTag
      def render(context)
        super
        link_to(@options["title"], @options["url"], class: options["class"])
      end
    end
    
    class LinkBlock < BaseBlock
      def render(context)
        link_to(@options["url"], class: @options["class"]) { super }
      end
    end

    class Header < BaseBlock
      def render(context)
        content_tag(:header, class: 'page-header') { buttonize markdown super } + image_tag(@options["image"], class: 'header-background')
      end
    end

    class EventCard < BaseTag
      def render(content)
        super
        @options.merge! @data["events"].find{|e| e["url"] == @args[0]}
        @options["class"].push "card event-card"
        @options["subtitle"] = "Featured Event"
        @options["image"] = File.join "events", @options["url"], @options["image"]

        content = content_tag(:div, class: 'event-date') { @options["dates"] }
        content << content_tag(:p) { @options["description"] }
        content << link_to("Learn More &rarr;", @options["url"], class: 'button-alt')

        card { content }
      end
    end
  end
end

Liquid::Template.register_tag('figure', Jekyll::Tags::Figure)
Liquid::Template.register_tag('header', Jekyll::Tags::Header)
Liquid::Template.register_tag('link_to', Jekyll::Tags::LinkTo)
Liquid::Template.register_tag('link', Jekyll::Tags::LinkBlock)
Liquid::Template.register_tag('event_card', Jekyll::Tags::EventCard)
