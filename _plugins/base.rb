module Jekyll
  module Tags
    module HelperTag
      def markdown(str)
        # Ensure that markdown titles are separated by new lines
        str = str.gsub(/^(#.+$)/) { "\n#{$1}" }
        Kramdown::Document.new(str).to_html
      end

      def extract_args
        @markup.split(/(".+?")/).reject(&:empty?).each do |arg|
          if arg.match(/"/)
            @text.push arg.gsub(/"/,'')
          else
            @args.concat arg.split(' ')
          end
        end
      end

      def process_args
        extract_args

        @options[:title] = @text[0]
        @options[:description] = @text[1]

        @args.each do |arg|
          if arg.match(/^\.\S+/)
            @options[:class].concat arg.gsub('.',' ').split(' ')
          elsif arg.match(/^\$/)
            @options[:price] = arg
          elsif arg.match(/\.(jpg|jpeg|png|gif)/)
            @options[:image] = arg
          elsif arg.match(/(vimeo|youtube|\.mp4)/)
            @options[:video] = arg
          elsif arg.match(/:\/\//) || arg.match(/^\//)
            @options[:url] = arg
          end
        end
      end

      def image_path(path)
        File.join @config["baseurl"], @config["image_dir"], path
      end

      def img_tag(path=@options[:image])
        %Q{<img src="#{image_path path}">}
      end

      def figure_tag(classname='', image=@options[:image])
        %Q{<figure class="#{classname}">#{image}</figure>}
      end
    end

    class BaseTag < Liquid::Tag
      include HelperTag

      def initialize(tag_name, markup, tokens)
        super
        @markup = markup
        @options = { class: [] }
        @args = []
        @text = []
        process_args
      end

      def render(context)
        @site = context.registers[:site]
        @config = @site.config
      end
    end

    class BaseBlock < Liquid::Block
      include HelperTag

      def initialize(tag_name, markup, tokens)
        super
        @markup = markup
        @options = { class: [] }
        @args = []
        @text = []
        process_args
      end

      def render(context)
        @site = context.registers[:site]
        @config = @site.config
        super
      end
    end

    class Test < BaseTag
      def render(context)
        super
        @options.inspect
      end
    end
  end
end


Liquid::Template.register_tag('test', Jekyll::Tags::Test)
