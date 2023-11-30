# frozen_string_literal: true

module StorageHelper
  def storage_url(attachment)
    attachment&.url(virtual_host: use_virtual_host_storage?)
  end

  def use_virtual_host_storage?
    ENV.fetch("CELLAR_VIRTUAL_HOST", "false") == "true"
  end
end
