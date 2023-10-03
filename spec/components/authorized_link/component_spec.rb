# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuthorizedLink::Component, type: :component do
  context "with organization namespace" do
    context "when signed in as a publisher admin" do
      let(:publisher) { create(:publisher) }

      before { sign_in_as(:organization_admin, organization: publisher) }

      it "renders user's link when user is a member of the current organization" do
        user = create(:user, organization: publisher)

        render_inline described_class.new(user, namespace: :organization)

        expect(page).to have_link(user.name, href: "/organisation/utilisateurs/#{user.id}")
      end

      it "renders user's link when user is a member of a collectivity managed by the current organization" do
        collectivity = create(:collectivity, publisher: publisher, allow_publisher_management: true)
        user         = create(:user, organization: collectivity)

        render_inline described_class.new(user, namespace: :organization, parent: collectivity)

        expect(page).to have_link(user.name, href: "/organisation/collectivites/#{collectivity.id}/utilisateurs/#{user.id}")
      end

      it "renders user's name when user is a member of a collectivity not managed by the current organization" do
        collectivity = create(:collectivity, publisher: publisher, allow_publisher_management: false)
        user         = create(:user, organization: collectivity)

        render_inline described_class.new(user, namespace: :organization, parent: collectivity)

        expect(page).to     have_text(user.name)
        expect(page).not_to have_link
      end

      it "renders user's name when user is not a member of the current organization" do
        user = create(:user)

        render_inline described_class.new(user, namespace: :organization)

        expect(page).to have_text(user.name)
        expect(page).not_to have_link
      end

      it "renders user's name when user is discarded" do
        user = create(:user, :discarded, organization: publisher)

        render_inline described_class.new(user, namespace: :organization)

        expect(page).to have_selector(".text-disabled", text: "#{user.name} (utilisateur supprimé)")
        expect(page).not_to have_link
      end

      it "renders collectivity's link when collectivity is owned by current organization" do
        collectivity = create(:collectivity, publisher: publisher)

        render_inline described_class.new(collectivity, namespace: :organization)

        expect(page).to have_link(collectivity.name, href: "/organisation/collectivites/#{collectivity.id}")
      end

      it "renders collectivity's name when collectivity is not owned by current organization" do
        collectivity = create(:collectivity)

        render_inline described_class.new(collectivity, namespace: :organization)

        expect(page).to have_text(collectivity.name)
        expect(page).not_to have_link
      end

      it "renders collectivity's name when organization is discarded" do
        collectivity = create(:collectivity, :discarded, publisher: publisher)

        render_inline described_class.new(collectivity, namespace: :organization)

        expect(page).to have_selector(".text-disabled", text: "#{collectivity.name} (organisation supprimée)")
        expect(page).not_to have_link
      end

      it "renders territory's name" do
        commune = create(:commune)

        render_inline described_class.new(commune, namespace: :organization)

        expect(page).to have_text(commune.name)
        expect(page).not_to have_link
      end

      it "renders DDFIP's name" do
        ddfip = create(:ddfip)

        render_inline described_class.new(ddfip, namespace: :organization)

        expect(page).to have_text(ddfip.name)
        expect(page).not_to have_link
      end

      it "renders office's name" do
        office = create(:office)

        render_inline described_class.new(office, namespace: :organization)

        expect(page).to have_text(office.name)
        expect(page).not_to have_link
      end
    end

    context "when signed in as a publisher user" do
      let(:publisher) { create(:publisher) }

      before { sign_in_as(organization: publisher) }

      it "renders user's name when user is a member of the current organization" do
        user = create(:user, organization: publisher)

        render_inline described_class.new(user, namespace: :organization)

        expect(page).to have_text(user.name)
        expect(page).not_to have_link
      end

      it "renders user's link when user is a member of a collectivity managed by the current organization" do
        collectivity = create(:collectivity, publisher: publisher, allow_publisher_management: true)
        user         = create(:user, organization: collectivity)

        render_inline described_class.new(user, namespace: :organization, parent: collectivity)

        expect(page).to have_link(user.name, href: "/organisation/collectivites/#{collectivity.id}/utilisateurs/#{user.id}")
      end

      it "renders user's name when user is a member of a collectivity not managed by the current organization" do
        collectivity = create(:collectivity, publisher: publisher, allow_publisher_management: false)
        user         = create(:user, organization: collectivity)

        render_inline described_class.new(user, namespace: :organization, parent: collectivity)

        expect(page).to     have_text(user.name)
        expect(page).not_to have_link
      end

      it "renders user's name when user is discarded" do
        user = create(:user, :discarded, organization: publisher)

        render_inline described_class.new(user, namespace: :organization)

        expect(page).to have_selector(".text-disabled", text: "#{user.name} (utilisateur supprimé)")
        expect(page).not_to have_link
      end

      it "renders collectivity's link when collectivity is owned by current organization" do
        collectivity = create(:collectivity, publisher: publisher)

        render_inline described_class.new(collectivity, namespace: :organization)

        expect(page).to have_link(collectivity.name, href: "/organisation/collectivites/#{collectivity.id}")
      end

      it "renders collectivity's name when collectivity is not owned by current organization" do
        collectivity = create(:collectivity)

        render_inline described_class.new(collectivity, namespace: :organization)

        expect(page).to have_text(collectivity.name)
        expect(page).not_to have_link
      end

      it "renders collectivity's name when organization is discarded" do
        collectivity = create(:collectivity, :discarded, publisher: publisher)

        render_inline described_class.new(collectivity, namespace: :organization)

        expect(page).to have_selector(".text-disabled", text: "#{collectivity.name} (organisation supprimée)")
        expect(page).not_to have_link
      end
    end

    context "when signed in as a DDFIP admin" do
      let(:ddfip) { create(:ddfip) }

      before { sign_in_as(:organization_admin, organization: ddfip) }

      it "renders user's link when user is a member of the current organization" do
        user = create(:user, organization: ddfip)

        render_inline described_class.new(user, namespace: :organization)

        expect(page).to have_link(user.name, href: "/organisation/utilisateurs/#{user.id}")
      end

      it "renders user's link within office context" do
        office = create(:office, ddfip:)
        user   = create(:user, organization: ddfip, offices: [office])

        render_inline described_class.new(user, namespace: :organization, parent: office)

        expect(page).to have_link(user.name, href: "/organisation/utilisateurs/#{user.id}")
      end

      it "renders user's name when user is not a member of the current organization" do
        user = create(:user)

        render_inline described_class.new(user, namespace: :organization)

        expect(page).to have_text(user.name)
        expect(page).not_to have_link
      end

      it "renders user's name when user is discarded" do
        user = create(:user, :discarded, organization: ddfip)

        render_inline described_class.new(user, namespace: :organization)

        expect(page).to have_selector(".text-disabled", text: "#{user.name} (utilisateur supprimé)")
        expect(page).not_to have_link
      end

      it "renders office's link when office is part of the current DDFIP" do
        office = create(:office, ddfip: ddfip)

        render_inline described_class.new(office, namespace: :organization)

        expect(page).to have_link(office.name, href: "/organisation/guichets/#{office.id}")
      end

      it "renders office's name when office is not part of the current DDFIP" do
        office = create(:office)

        render_inline described_class.new(office, namespace: :organization)

        expect(page).to have_text(office.name)
        expect(page).not_to have_link
      end

      it "renders office's name when office is discarded" do
        office = create(:office, :discarded, ddfip: ddfip)

        render_inline described_class.new(office, namespace: :organization)

        expect(page).to have_selector(".text-disabled", text: "#{office.name} (guichet supprimé)")
        expect(page).not_to have_link
      end

      it "renders collectivity's link when collectivity is on DDFIP's territory" do
        commune      = create(:commune, departement: ddfip.departement)
        collectivity = create(:collectivity, territory: commune)

        render_inline described_class.new(collectivity, namespace: :organization)

        expect(page).to have_link(collectivity.name, href: "/organisation/collectivites/#{collectivity.id}")
      end

      it "renders collectivity's name when collectivity is not on DDFIP's territory" do
        collectivity = create(:collectivity)

        render_inline described_class.new(collectivity, namespace: :organization)

        expect(page).to have_text(collectivity.name)
        expect(page).not_to have_link
      end

      it "renders publisher's name" do
        publisher = create(:publisher)

        render_inline described_class.new(publisher, namespace: :organization)

        expect(page).to have_text(publisher.name)
        expect(page).not_to have_link
      end

      it "renders territory's name" do
        commune = create(:commune)

        render_inline described_class.new(commune, namespace: :organization)

        expect(page).to have_text(commune.name)
        expect(page).not_to have_link
      end
    end

    context "when signed in as a DDFIP user" do
      let(:ddfip) { create(:ddfip) }

      before { sign_in_as(organization: ddfip) }

      it "renders user's name when user is a member of the current organization" do
        user = create(:user, organization: ddfip)

        render_inline described_class.new(user, namespace: :organization)

        expect(page).to have_text(user.name)
        expect(page).not_to have_link
      end

      it "renders office's name when office is part of the current DDFIP" do
        office = create(:office, ddfip: ddfip)

        render_inline described_class.new(office, namespace: :organization)

        expect(page).to have_text(office.name)
        expect(page).not_to have_link
      end
    end

    context "when signed in as a collectvity admin" do
      let(:collectivity) { create(:collectivity) }

      before { sign_in_as(:organization_admin, organization: collectivity) }

      it "renders user's link when user is a member of the current organization" do
        user = create(:user, organization: collectivity)

        render_inline described_class.new(user, namespace: :organization)

        expect(page).to have_link(user.name, href: "/organisation/utilisateurs/#{user.id}")
      end

      it "renders user's name when user is not a member of the current organization" do
        user = create(:user)

        render_inline described_class.new(user, namespace: :organization)

        expect(page).to have_text(user.name)
        expect(page).not_to have_link
      end

      it "renders user's name when user is discarded" do
        user = create(:user, :discarded, organization: collectivity)

        render_inline described_class.new(user, namespace: :organization)

        expect(page).to have_selector(".text-disabled", text: "#{user.name} (utilisateur supprimé)")
        expect(page).not_to have_link
      end

      it "renders collectivity's name" do
        render_inline described_class.new(collectivity, namespace: :organization)

        expect(page).to have_text(collectivity.name)
        expect(page).not_to have_link
      end

      it "renders territory's name" do
        render_inline described_class.new(collectivity.territory, namespace: :organization)

        expect(page).to have_text(collectivity.territory.name)
        expect(page).not_to have_link
      end

      it "renders DDFIP's name" do
        ddfip = create(:ddfip)

        render_inline described_class.new(ddfip, namespace: :organization)

        expect(page).to have_text(ddfip.name)
        expect(page).not_to have_link
      end

      it "renders office's name" do
        office = create(:office)

        render_inline described_class.new(office, namespace: :organization)

        expect(page).to have_text(office.name)
        expect(page).not_to have_link
      end
    end

    context "when signed in as a super admin" do
      before { sign_in_as(:super_admin) }

      it "renders publisher's link" do
        publisher = create(:publisher)

        render_inline described_class.new(publisher, namespace: :organization)

        expect(page).to have_link(publisher.name, href: "/admin/editeurs/#{publisher.id}")
      end

      it "renders DDFIP's link" do
        ddfip = create(:ddfip)

        render_inline described_class.new(ddfip, namespace: :organization)

        expect(page).to have_link(ddfip.name, href: "/admin/ddfips/#{ddfip.id}")
      end

      it "renders commune's link" do
        commune = create(:commune)

        render_inline described_class.new(commune, namespace: :organization)

        expect(page).to have_link(commune.name, href: "/territoires/communes/#{commune.id}")
      end

      it "renders EPCI's link" do
        epci = create(:epci)

        render_inline described_class.new(epci, namespace: :organization)

        expect(page).to have_link(epci.name, href: "/territoires/epcis/#{epci.id}")
      end

      it "renders departement's link" do
        departement = create(:departement)

        render_inline described_class.new(departement, namespace: :organization)

        expect(page).to have_link(departement.name, href: "/territoires/departements/#{departement.id}")
      end

      it "renders region's link" do
        region = create(:region)

        render_inline described_class.new(region, namespace: :organization)

        expect(page).to have_link(region.name, href: "/territoires/regions/#{region.id}")
      end
    end
  end

  context "with admin namespace" do
    before { sign_in_as(:super_admin) }

    it "renders user's link" do
      user = create(:user)

      render_inline described_class.new(user, namespace: :admin)

      expect(page).to have_link(user.name, href: "/admin/utilisateurs/#{user.id}")
    end

    it "renders user's link in organization context" do
      user = create(:user)

      render_inline described_class.new(user, namespace: :admin, parent: user.organization)

      expect(page).to have_link(user.name, href: "/admin/utilisateurs/#{user.id}")
    end

    it "renders user's link in office context" do
      ddfip  = create(:ddfip)
      office = create(:office, ddfip:)
      user   = create(:user, organization: ddfip, offices: [office])

      render_inline described_class.new(user, namespace: :admin, parent: office)

      expect(page).to have_link(user.name, href: "/admin/utilisateurs/#{user.id}")
    end

    it "renders user's name when user is discarded" do
      user = create(:user, :discarded)

      render_inline described_class.new(user, namespace: :admin)

      expect(page).to have_selector(".text-disabled", text: "#{user.name} (utilisateur supprimé)")
      expect(page).not_to have_link
    end

    it "renders publisher's link" do
      publisher = create(:publisher)

      render_inline described_class.new(publisher, namespace: :admin)

      expect(page).to have_link(publisher.name, href: "/admin/editeurs/#{publisher.id}")
    end

    it "renders publisher's name when organization is discarded" do
      publisher = create(:publisher, :discarded)

      render_inline described_class.new(publisher, namespace: :admin)

      expect(page).to have_selector(".text-disabled", text: "#{publisher.name} (organisation supprimée)")
      expect(page).not_to have_link
    end

    it "renders collectivity's link" do
      collectivity = create(:collectivity)

      render_inline described_class.new(collectivity, namespace: :admin)

      expect(page).to have_link(collectivity.name, href: "/admin/collectivites/#{collectivity.id}")
    end

    it "renders collectivity's name when organization is discarded" do
      collectivity = create(:collectivity, :discarded)

      render_inline described_class.new(collectivity, namespace: :admin)

      expect(page).to have_selector(".text-disabled", text: "#{collectivity.name} (organisation supprimée)")
      expect(page).not_to have_link
    end

    it "renders DDFIP's link" do
      ddfip = create(:ddfip)

      render_inline described_class.new(ddfip, namespace: :admin)

      expect(page).to have_link(ddfip.name, href: "/admin/ddfips/#{ddfip.id}")
    end

    it "renders DDFIP's name when organization is discarded" do
      ddfip = create(:ddfip, :discarded)

      render_inline described_class.new(ddfip, namespace: :admin)

      expect(page).to have_selector(".text-disabled", text: "#{ddfip.name} (organisation supprimée)")
      expect(page).not_to have_link
    end

    it "renders office's link" do
      office = create(:office)

      render_inline described_class.new(office, namespace: :admin)

      expect(page).to have_link(office.name, href: "/admin/guichets/#{office.id}")
    end

    it "renders office's name when office is discarded" do
      office = create(:office, :discarded)

      render_inline described_class.new(office, namespace: :admin)

      expect(page).to have_selector(".text-disabled", text: "#{office.name} (guichet supprimé)")
      expect(page).not_to have_link
    end

    it "renders commune's link" do
      commune = create(:commune)

      render_inline described_class.new(commune, namespace: :admin)

      expect(page).to have_link(commune.name, href: "/territoires/communes/#{commune.id}")
    end

    it "renders EPCI's link" do
      epci = create(:epci)

      render_inline described_class.new(epci, namespace: :admin)

      expect(page).to have_link(epci.name, href: "/territoires/epcis/#{epci.id}")
    end

    it "renders departement's link" do
      departement = create(:departement)

      render_inline described_class.new(departement, namespace: :admin)

      expect(page).to have_link(departement.name, href: "/territoires/departements/#{departement.id}")
    end

    it "renders region's link" do
      region = create(:region)

      render_inline described_class.new(region, namespace: :admin)

      expect(page).to have_link(region.name, href: "/territoires/regions/#{region.id}")
    end
  end

  context "with territories namespace" do
    context "when signed in as a super admin" do
      before { sign_in_as(:super_admin) }

      it "renders commune's link" do
        commune = create(:commune)

        render_inline described_class.new(commune, namespace: :territories)

        expect(page).to have_link(commune.name, href: "/territoires/communes/#{commune.id}")
      end

      it "renders EPCI's link" do
        epci = create(:epci)

        render_inline described_class.new(epci, namespace: :territories)

        expect(page).to have_link(epci.name, href: "/territoires/epcis/#{epci.id}")
      end

      it "renders departement's link" do
        departement = create(:departement)

        render_inline described_class.new(departement, namespace: :territories)

        expect(page).to have_link(departement.name, href: "/territoires/departements/#{departement.id}")
      end

      it "renders region's link" do
        region = create(:region)

        render_inline described_class.new(region, namespace: :territories)

        expect(page).to have_link(region.name, href: "/territoires/regions/#{region.id}")
      end

      it "renders publisher's link" do
        publisher = create(:publisher)

        render_inline described_class.new(publisher, namespace: :territories)

        expect(page).to have_link(publisher.name, href: "/admin/editeurs/#{publisher.id}")
      end

      it "renders DDFIP's link" do
        ddfip = create(:ddfip)

        render_inline described_class.new(ddfip, namespace: :territories)

        expect(page).to have_link(ddfip.name, href: "/admin/ddfips/#{ddfip.id}")
      end

      it "renders collectivity's link" do
        collectivity = create(:collectivity)

        render_inline described_class.new(collectivity, namespace: :territories)

        expect(page).to have_link(collectivity.name, href: "/admin/collectivites/#{collectivity.id}")
      end

      it "renders office's link" do
        office = create(:office)

        render_inline described_class.new(office, namespace: :territories)

        expect(page).to have_link(office.name, href: "/admin/guichets/#{office.id}")
      end
    end
  end

  context "without namespace" do
    context "when signed in as a collectvity user" do
      let(:collectivity) { create(:collectivity) }

      before { sign_in_as(organization: collectivity) }

      it "renders report's link" do
        report = create(:report, :completed, collectivity: collectivity, form_type: "evaluation_local_habitation")

        render_inline described_class.new(report)

        expect(page).to have_link(
          "Évaluation du local d'habitation #{report.situation_invariant}",
          href: "/signalements/#{report.id}"
        )
      end

      it "renders package's link" do
        package = create(:package, collectivity: collectivity)

        render_inline described_class.new(package)

        expect(page).to have_link(package.reference, href: "/paquets/#{package.id}")
      end

      it "renders publisher's name" do
        publisher = create(:publisher)

        render_inline described_class.new(publisher)

        expect(page).to have_text(publisher.name)
        expect(page).not_to have_link
      end

      it "renders DDFIP's name" do
        ddfip = create(:ddfip)

        render_inline described_class.new(ddfip)

        expect(page).to have_text(ddfip.name)
        expect(page).not_to have_link
      end

      it "renders collectivity's name" do
        render_inline described_class.new(collectivity)

        expect(page).to have_text(collectivity.name)
        expect(page).not_to have_link
      end

      it "renders office's link" do
        office = create(:office)

        render_inline described_class.new(office)

        expect(page).to have_text(office.name)
        expect(page).not_to have_link
      end
    end
  end

  describe "customization" do
    before { sign_in_as(:super_admin) }

    it "allows to override link label" do
      departement = create(:departement)

      render_inline described_class.new(departement, namespace: :admin) do
        "Departement de #{departement.name}"
      end

      expect(page).to have_link("Departement de #{departement.name}")
    end

    it "allows to override URL" do
      user = create(:user)

      render_inline described_class.new(user, "/custom/path/to/#{user.id}", namespace: :admin)

      expect(page).to have_link(href: "/custom/path/to/#{user.id}")
    end

    it "allows to add HTML attributes" do
      user = create(:user)

      render_inline described_class.new(user, namespace: :admin, data: { action: "click->do_something" })

      expect(page).to have_link(user.name) do |link|
        expect(link).to have_html_attribute("data-action").with_value("click->do_something")
      end
    end
  end
end
