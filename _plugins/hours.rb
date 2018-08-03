module Jekyll
  module Tags
    class Hours < BaseTag
      def render(context)
        super
        hours = @site.data['hours']

        h = hours[@args.first]

        now = Time.now

        # DST Hours
        h ||= if now.isdst
          hours["dst"]
        # Off Season January & February
        elsif hours["off-season"] & [1,2].include?(now.month)
          hours["off-season"]
        # Normal Hours
        else
          hours["default"]
        end

        h = Array(h).join("<br>")
        
        content_tag(:p, h)

      end
    end
  end
end

Liquid::Template.register_tag('hours', Jekyll::Tags::Hours)
