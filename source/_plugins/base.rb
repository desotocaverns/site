module Jekyll
  module Tags
    module HelperTag
      def markdown(str)
        # Ensure that markdown titles are separated by new lines
        str = str.gsub(/^(#.+$)/) { "\n#{$1}" }
        Kramdown::Document.new(str).to_html
      end

      def buttonize(content)
        content.gsub(/button:(<a.+?\/a>)/) do
          %Q{#{$1.sub(/<a /, '<a class="button" ')}}
        end
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
        @options = { "class" => [] }
        @args = []
        @text = []

        extract_args

        @options["title"] = @text[0]
        @options["subtitle"] = @text[1]

        @args.each do |arg|
          if arg.match(/^\.\S+/)
            @options["class"].concat arg.gsub('.',' ').split(' ')
          elsif arg.match(/^\$/)
            @options["price"] = arg
          elsif arg.match(/\.(jpg|jpeg|png|gif)/)
            @options["image"] = arg
          elsif arg.match(/(vimeo|youtube|\.mp4)/)
            @options["video"] = arg
          elsif arg.match(/:\/\//) || arg.match(/^\//)
            @options["url"] = arg
          end
        end
      end

      def image_path(path)
        File.join @config["baseurl"], @config["image_dir"], path
      end

      def header_image(image)
        image_tag(image, class: 'header-image') +
        content_tag(:span, style: "background-image: url(#{image_path(image)}", class: 'header-bg') {''}
      end

      def card(&block)
        header = ''
        if @options["image"]
          @options["class"].push "photo-card"
          header << header_image(@options["image"])
        end
        header << content_tag(:h6, class: 'card-subtitle') { @options["subtitle"] } if @options["subtitle"]
        header << content_tag(:h4, class: 'card-title') { @options["title"] } if @options["title"]
        header << @options["header-content"] if @options["header-content"]

        unless header.empty?
          header = content_tag(:header, class: "card-header #{"photo-header" if @options["image"]}") { header }
        end

        content_tag(:div, class: @options["class"]) {
          header + content_tag(:div, class: 'card-content', &block)
        }
      end

      def image_tag(src=@options[:image], options={})
        options[:src] = image_path options[:src] || src
        tag(:img, options)
      end

      def figure_tag(image, options={})
        content_tag(:figure, options) { image_tag(image) }
      end

      def link_to(name = nil, url = nil, html_options = nil, &block)
        html_options, url, name = url, name, nil if block_given?
        html_options ||= {}
        html_options[:href] ||= url

        content_tag :a, name || url, html_options, &block
      end
        
      def content_tag(name, content_or_options_with_block = nil, options = nil, &block)
        if block_given?
          options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
          content_tag_string(name, capture(&block), options)
        else
          content_tag_string(name, content_or_options_with_block, options)
        end
      end

      def content_tag_string(name, content, options)
        tag_options = tag_options(options) if options
        "<#{name}#{tag_options}>#{content}</#{name}>"
      end

      def tag_option(key, value)
        if value.is_a?(Array)
          value = value.join(" ")
        else
          value = value
        end
        %(#{key}="#{value}")
      end

      def boolean_tag_option(key)
        %(#{key}="#{key}")
      end

      def tag_options(options)
        return if options.nil? || options.keys.empty?
        attrs = []
        options.each_pair do |key, value|
          if ["aria", "data", :aria, :data].include?(key) && value.is_a?(Hash)
            value.each_pair do |k, v|
              attrs << prefix_tag_option(key, k, v)
            end
          elsif %w(allowfullscreen async autofocus autoplay checked compact controls declare default defaultchecked defaultmuted defaultselected defer disabled enabled formnovalidate hidden indeterminate inert ismap itemscope loop multiple muted nohref noresize noshade novalidate nowrap open pauseonexit readonly required reversed scoped seamless selected sortable truespeed typemustmatch visible).include?(key)
            attrs << boolean_tag_option(key) if value
          elsif !value.nil?
            attrs << tag_option(key, value)
          end
        end
        " #{attrs * ' '}" unless attrs.empty?
      end

      def tag(name, options = nil, open = false)
        "<#{name}#{tag_options(options) if options}#{open ? ">" : " />"}"
      end

      def capture(*args)
        value = nil
        value = yield(*args)
      end
    end

    class BaseTag < Liquid::Tag
      include HelperTag

      def initialize(tag_name, markup, tokens)
        super
        @markup = markup
      end

      def render(context)
        process_args
        @site = context.registers[:site]
        @page = context.registers[:page]
        @data = @site.data
        @config = @site.config
      end
    end

    class BaseBlock < Liquid::Block
      include HelperTag

      def initialize(tag_name, markup, tokens)
        super
        @markup = markup
      end

      def render(context)
        process_args
        @site = context.registers[:site]
        @page = context.registers[:page]
        @data = @site.data
        @config = @site.config
        super
      end
    end
  end
end
