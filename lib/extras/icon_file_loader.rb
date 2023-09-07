# frozen_string_literal: true

class IconFileLoader
  SEARCH_PATHS = [
    Rails.root.join("app/assets/icons"),
    Rails.root.join("app/assets/images"),
    Rails.root.join("vendor/assets/icons")
  ].freeze

  CACHE_MAX_SIZE = 100.kilobytes.freeze

  def initialize(cache: false)
    @cache = ActiveSupport::Cache::MemoryStore.new(size: CACHE_MAX_SIZE) if cache
  end

  # Finds the named asset and returns the contents as a string.
  #
  def named(path)
    svg(path) or raise InlineSvg::AssetFile::FileNotFound, "Asset not found: #{path}"
  end

  private

  def svg(path)
    if @cache
      @cache.fetch(path) do
        find_asset(path)&.read
      end
    else
      find_asset(path)&.read
    end
  end

  def find_asset(icon_path)
    SEARCH_PATHS.each do |search_path|
      path = search_path.join(icon_path)

      return path if path.exist? && path.readable_real?
    end

    nil
  end
end
