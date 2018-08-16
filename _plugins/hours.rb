module Jekyll
  module Tags
    class Hours < BaseTag
      def render(context)
        super
        hours = @data['hours']
        now = Time.now

        # DST Hours
        h = hours[@args.first] || if now.isdst
          hours["dst"]
        # Off Season January & February
        elsif hours["off-season"] & [1,2].include?(now.month)
          hours["off-season"]
        # Normal Hours
        else
          hours["default"]
        end

        h = Array(h).join("<br>")
        
        content_tag(:span, h, class: 'hours')

      end
    end
  end
end

Liquid::Template.register_tag('hours', Jekyll::Tags::Hours)
