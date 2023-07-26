# frozen_string_literal: true

module FlashAction
  CACHE_NAMESPACE  = "flash_actions"
  CACHE_KEY_REGEXP = %r{\Aflash_actions/.*}

  class << self
    def write(action)
      action = action.to_h
      return action if action.empty? || null_cache_store?

      cache_key = expand_cache_key(action)
      Rails.cache.write(cache_key, action)
      cache_key
    end

    def write_multi(actions)
      actions = actions.filter_map { |action| action.to_h.presence }
      return actions if actions.empty? || null_cache_store?

      entries = actions.index_by { |action| expand_cache_key(action) }
      Rails.cache.write_multi(entries)
      entries.keys
    end

    def read(action)
      return action if action.blank? || null_cache_store?
      return unless CACHE_KEY_REGEXP.match?(action)

      Rails.cache.read(action)&.symbolize_keys
    end

    def read_multi(actions)
      return actions if actions.blank? || null_cache_store?

      actions = Array.wrap(actions)
      cached_keys = actions.grep(CACHE_KEY_REGEXP)
      cached_actions = Rails.cache.read_multi(*cached_keys)

      actions.filter_map do |action|
        (cached_actions[action] || action)&.symbolize_keys
      end
    end

    protected

    def null_cache_store?
      Rails.cache.is_a?(ActiveSupport::Cache::NullStore)
    end

    def expand_cache_key(action)
      cache_key = ActiveSupport::Cache.expand_cache_key(action.to_h)
      cache_key = Digest::SHA256.hexdigest(cache_key)
      ActiveSupport::Cache.expand_cache_key(cache_key, CACHE_NAMESPACE)
    end
  end
end
