# frozen_string_literal: true

module Icon
  class Component < ApplicationViewComponent
    SETS = %i[
      auto
      assets
      heroicon
    ].freeze

    VARIANTS = %i[
      outline
      solid
    ].freeze

    def initialize(icon, title = nil, set: :auto, variant: :outline, **options)
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
      with_cache do
        svg
          .strip
          .gsub(%(aria-hidden="true"), "aria-hidden")
          .gsub(%r{></(path|circle|rect)>}, "/>")
          .html_safe # rubocop:disable Rails/OutputSafety
      end
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

    def set
      return @set      if @set != :auto
      return :assets   if asset_exist?
      return :heroicon if heroicon_exist?

      :assets
    end

    def asset_exist?
      ::InlineSvg.configuration.asset_file.named("#{@icon}.svg")
    rescue InlineSvg::AssetFile::FileNotFound
      false
    end

    def heroicon_exist?
      ::InlineSvg.configuration.asset_file.named("heroicons/outline/#{@icon}.svg")
    rescue InlineSvg::AssetFile::FileNotFound
      false
    end

    # Caching
    # --------------------------------------------------------------------------
    CACHE_LOOKUP = {} # rubocop:disable Style/MutableConstant

    def with_cache
      # TODO
      yield
    end

    # SVG reading
    # --------------------------------------------------------------------------
    def svg
      case set
      when :assets   then assets_svg
      when :heroicon then heroicon_svg
      end
    end

    def assets_svg
      helpers.inline_svg_tag("#{@icon}.svg", **transform_options)
    end

    def heroicon_svg
      path = "heroicons/outline/#{@icon}.svg"
      path = "heroicons/solid/#{@icon}.svg" if @variant == :solid

      helpers.inline_svg_tag(path, **transform_options)
    end

    def transform_options
      options = @options.dup

      if @title
        options[:title] = @title
        options[:aria] ||= true
      else
        options[:aria_hidden] = true
      end

      # Set default size, overwriten by CSS to avoid render full-page icons
      # when CSS take time to load.
      options[:height] ||= 24
      options[:width]  ||= 24
      options
    end
  end
end
