# frozen_string_literal: true

module ControllerAudits
  def load_audits_collection(audits, with_policy: nil)
    scope = authorized_scope(audits, with: with_policy)

    if turbo_frame_request_id == "audits"
      index_collection(scope, nested: true)
    else
      index_collection(scope, limit: 100)
    end
  end
end
