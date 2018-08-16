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
        content = buttonize(markdown(super))

        content = content.gsub(/(\/h\d>)(\s+<p>.+)/m) do
          %Q{#{$1}<div class='header-call-to-action'>#{$2}</div>}
        end

        content_tag(:header, class: 'page-header photo-header') { 
           content + header_image(@options["image"])
        } 
      end
    end
    
    class Box < BaseBlock
      def render(context)
        @options["class"].push "box"
        content_tag(:div, class: @options["class"]) { buttonize(markdown(super)) }
      end
    end

    class EventCard < BaseTag
      def render(context)
        super
        @options.merge! @data["events"].find{|e| e["url"] == @args[0]}
        @options["class"].push "card event-card"
        @options["subtitle"] = "Featured Event"
        @options["image"] = File.join "events", @options["url"], @options["image"]

        content = content_tag(:h5, class: 'event-date') { @options["dates"] }
        content << content_tag(:p) { @options["description"] }
        content << content_tag(:p) { link_to("Learn More &rarr;", @options["url"], class: 'button-alt') }

        card { content }
      end
    end

    class Markdown < BaseBlock
      def render(context)
        buttonize(markdown(super))
      end
    end

    class Contact < BaseTag
      def render(context)
        super
        content = []
        contact = @data["contact"]

        if @args.include?("address")
          street = contact["address"][0]
          match, city, state, zip = contact["address"][1].match(/(.+?),\s*(.+?)\s*(\d+)/).to_a

          content.push %Q{<a title="Get Directions" target="_blank" href="https://www.google.com/maps/search/?api=1&query=#{contact["address"].join(' ')}" class="adr"><span class="street-address">#{street}</span><br>
<span class="locality">#{city}</span>, <span class="region">#{state}</span> <span class="postal-code">#{zip}</span></a>}
        end

        if @args.include?("map")
          content.push %Q{<a class="map-address" href="https://www.google.com/maps/search/?api=1&query=#{contact["address"].join(' ')}">Get directions &rarr;</a>}
        end

        if @args.include?("phone")
          content.push %Q{<a class="tel" href="tel:#{contact["phone"].gsub(/\(|\)/, '').split(/\D/).join('-')}">#{contact["phone"]}</a>}
        end

        if @args.include?("group_phone")
          content.push %Q{<a class="tel" href="tel:#{contact["group_phone"].gsub(/\(|\)/, '').split(/\D/).join('-')}">#{contact["group_phone"]}</a>}
        end

        if @args.include?("email")
          content.push %Q{<a class="email" href="mailto:#{contact["email"]}">#{contact["email"]}</a>}
        end

        content_tag(:span, class: 'vcard') { content.join("<br>") }
      end

    end
  end
end

Liquid::Template.register_tag('figure', Jekyll::Tags::Figure)
Liquid::Template.register_tag('header', Jekyll::Tags::Header)
Liquid::Template.register_tag('link_to', Jekyll::Tags::LinkTo)
Liquid::Template.register_tag('link', Jekyll::Tags::LinkBlock)
Liquid::Template.register_tag('event_card', Jekyll::Tags::EventCard)
Liquid::Template.register_tag('contact', Jekyll::Tags::Contact)
Liquid::Template.register_tag('markdown', Jekyll::Tags::Markdown)
Liquid::Template.register_tag('box', Jekyll::Tags::Box)
