# frozen_string_literal: true

module UI
  class IconComponent < ApplicationViewComponent
    define_component_helper :icon_component

    SETS = %i[
      auto
      assets
      heroicon
    ].freeze

    VARIANTS = %i[
      outline
      solid
    ].freeze

    DEFAULT_VARIANT = :outline

    def initialize(icon, title = nil, set: :auto, variant: DEFAULT_VARIANT, **options)
      validate_set!(set)
      validate_variant!(variant)

      @icon    = icon
      @title   = title
      @set     = set
      @variant = variant
      @options = options

      super()
    end

    def call
      svg
        .strip
        .gsub(%r{></(path|circle|rect)>}, "/>") # Convert self-closed tags
        .html_safe                              # rubocop:disable Rails/OutputSafety
    end

    private

    include InlineSvg::ActionView::Helpers

    # Validate arguments
    # --------------------------------------------------------------------------
    def validate_set!(set)
      return true if SETS.include?(set)

      raise ArgumentError, "unexpected set argument: #{set.inspect}"
    end

    def validate_variant!(variant)
      return true if VARIANTS.include?(variant)

      raise ArgumentError, "unexpected variant argument: #{variant.inspect}"
    end

    # SVG reading
    # --------------------------------------------------------------------------
    def svg
      inline_svg_tag(icon_path, **icon_options)
    end

    def icon_path
      # rubocop:disable Lint/DuplicateBranch
      #
      # If `find_set` doesn't return an expected value,
      # we need to return a default path to passed to InlineSVG
      # which will return an empty SVG icon.
      #
      case find_set
      when :assets   then default_path
      when :heroicon then heroicon_path
      else default_path
      end
      # rubocop:enable Lint/DuplicateBranch
    end

    def find_set
      return @set unless @set == :auto

      if @variant == DEFAULT_VARIANT && icon_exist?(default_path)
        :assets
      elsif icon_exist?(heroicon_path)
        :heroicon
      end
    end

    def default_path
      "#{@icon}.svg"
    end

    def heroicon_path
      basename = @icon.tr("_", "-")

      case @variant
      when :outline then "heroicons/optimized/24/outline/#{basename}.svg"
      when :solid   then "heroicons/optimized/24/solid/#{basename}.svg"
      end
    end

    def icon_exist?(path)
      ::InlineSvg.configuration.asset_file.named(path)
    rescue InlineSvg::AssetFile::FileNotFound
      false
    end

    def icon_options
      options = @options.dup
      options[:data]              ||= {}
      options[:remove_attributes] ||= []

      merge_aria_attributes(options)
      merge_default_size(options)
      merge_data_source(options)

      options
    end

    # Define ARIA when title is present
    #
    def merge_aria_attributes(options)
      if @title
        options[:title] = @title
        options[:aria] ||= true
        options[:remove_attributes] << "aria_hidden" unless options[:aria_hidden]
      else
        options[:aria_hidden] = true
      end
    end

    # Set default size, overwriten by CSS to avoid render full-page icons
    # when CSS take time to load.
    #
    DEFAULT_SIZE = 24

    def merge_default_size(options)
      return if options.key?(:height) || options.key?(:width)

      options[:height] ||= DEFAULT_SIZE
      options[:width]  ||= DEFAULT_SIZE
    end

    # Add the source for testing & debugging purpose
    #
    def merge_data_source(options)
      options[:data][:source] = icon_path unless Rails.env.production?
    end
  end
end
