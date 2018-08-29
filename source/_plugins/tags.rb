require './source/_plugins/base'

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
        link_to(@options["title"], @options["url"], class: @options["class"])
      end
    end
    
    class LinkBlock < BaseBlock
      def render(context)
        super
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
        content = super
        @options["class"].push "box"
        content_tag(:div, class: @options["class"]) { buttonize(markdown(content)) }
      end
    end

    class Card < BaseBlock

      def render(context)
        content = super
        @options["class"].push "card"
        card { buttonize(markdown(content)) }
      end
    end

    class Hours < BaseTag
      def render(context)
        super
        hours = @data['hours']
        now = Time.now

        # DST Hours
        h = hours[@args.first] || if now.isdst
          hours["dst"]
        # Off Season January & February
        elsif hours["off-season"] && [1,2].include?(now.month)
          hours["off-season"]
        # Normal Hours
        else
          hours["default"]
        end

        h = Array(h).join("<br>")
        
        content_tag(:span, h, class: 'hours')

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

        map_url = "https://www.google.com/maps/search/?api=1&query=#{contact["address"].join(' ')}"

        if @args.include?("address")
          street = contact["address"][0]
          match, city, state, zip = contact["address"][1].match(/(.+?),\s*(.+?)\s*(\d+)/).to_a
          address = %Q{<span class="street-address">#{street}</span><br><span class="locality">#{city}</span>, <span class="region">#{state}</span> <span class="postal-code">#{zip}</span>}

          if @args.include?("link")
            address = Esvg.use('location') + address if @args.include?("icon")

            content.push link_to(address, map_url, class: 'contact-address adr has-tooltip', target: "_blank", "aria-label"=> "Get Directions")
          else
            content.push address
          end
        end

        if @args.include?("directions")
          directions = "Get directions &rarr;"
          directions = Esvg.use('location') + directions if @args.include?("icon")

          content.push link_to(directions, map_url, class: 'contact-directions')
        end

        if @args.include?("phone")
          phone = contact["phone"]
          phone = Esvg.use('phone') + phone if @args.include?("icon")

          content.push link_to(phone, "tel:#{contact["phone"].gsub(/\(|\)/, '').split(/\D/).join('-')}", class: 'contact-phone')
        end

        if @args.include?("group_phone")
          phone = contact["group_phone"]
          phone = Esvg.use('phone') + phone if @args.include?("icon")

          content.push link_to(phone, "tel:#{contact["group_phone"].gsub(/\(|\)/, '').split(/\D/).join('-')}", class: 'contact-phone contact-group-phone')
        end

        if @args.include?("email")
          email = contact["email"]
          email = Esvg.use('email') + email if @args.include?("icon")

          content.push link_to(email, "mailto:#{contact["email"]}", class: 'contact-email')
        end

        content_tag(:span, class: 'vcard') { content.join("<br>") }
      end

    end

    class Social < BaseTag
      def render(context)
        super

        network = @args.first

        if context[network]
          url     = context[network].last
          network = context[network].first
        else
          url     = @data["social"][network]
        end

        @options["class"].push "social-link has-tooltip"

        if network && url
          link_to(@options["url"], class: @options["class"], "aria-label" => network.capitalize) {
            Esvg.use(network, class: 'social-icon')
          }
        else
          raise "No social network configured for #{@args.first} in _data/social.yml"
        end
      end

    end
  end
end

#Liquid::Template.register_tag('figure', Jekyll::Tags::Figure)
Liquid::Template.register_tag('header', Jekyll::Tags::Header)
Liquid::Template.register_tag('link_to', Jekyll::Tags::LinkTo)
Liquid::Template.register_tag('link', Jekyll::Tags::LinkBlock)
Liquid::Template.register_tag('event_card', Jekyll::Tags::EventCard)
Liquid::Template.register_tag('contact', Jekyll::Tags::Contact)
#Liquid::Template.register_tag('markdown', Jekyll::Tags::Markdown)
Liquid::Template.register_tag('box', Jekyll::Tags::Box)
Liquid::Template.register_tag('hours', Jekyll::Tags::Hours)
Liquid::Template.register_tag('social', Jekyll::Tags::Social)
