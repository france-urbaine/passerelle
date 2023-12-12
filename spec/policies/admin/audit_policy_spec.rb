# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::AuditPolicy, type: :policy do
  describe_rule :index? do
    it_behaves_like("when current user is a super admin")        { succeed }
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher admin")    { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity admin") { failed }
    it_behaves_like("when current user is a collectivity user")  { failed }
  end

  describe "default relation scope" do
    subject!(:scope) { apply_relation_scope(user.audits) }

    let(:user) do
      u = create(:user)
      u.update!(
        last_name: "O'#{u.last_name}"
      )
      u
    end

    it_behaves_like "when current user is a super admin" do
      it "scopes all user audits" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "audits".*
          FROM     "audits"
          WHERE    "audits"."auditable_id" = '#{user.id}'
          AND      "audits"."auditable_type" = 'User'
          ORDER BY "audits"."version" ASC
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP admin")        { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP user")         { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher admin")    { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher user")     { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity admin") { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity user")  { it { is_expected.to be_a_null_relation } }
  end
end
