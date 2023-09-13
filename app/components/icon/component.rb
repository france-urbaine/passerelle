# frozen_string_literal: true

module Icon
  class Component < ApplicationViewComponent
    class FileNotFound < IOError; end

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
        .gsub(%r{></(path|circle|rect)>}, "/>")
        .html_safe # rubocop:disable Rails/OutputSafety
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
      inline_svg_tag(icon_path, **transform_options)
    end

    def icon_path
      case @set
      when :assets    then default_path
      when :heroicon  then heroicon_path
      when :auto
        if @variant == DEFAULT_VARIANT && icon_exist?(default_path)
          default_path
        elsif icon_exist?(heroicon_path)
          heroicon_path
        else # rubocop:disable Lint/DuplicateBranch
          default_path
        end
      end
    end

    def default_path
      "#{@icon}.svg"
    end

    def heroicon_path
      path = "heroicons/outline/#{@icon}.svg"
      path = "heroicons/solid/#{@icon}.svg" if @variant == :solid
      path
    end

    def icon_exist?(path)
      ::InlineSvg.configuration.asset_file.named(path)
    rescue InlineSvg::AssetFile::FileNotFound
      false
    end

    def transform_options
      options = @options.dup
      options[:remove_attributes] ||= []

      if @title
        options[:title] = @title
        options[:aria] ||= true
        options[:remove_attributes] << "aria_hidden" unless options[:aria_hidden]
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
