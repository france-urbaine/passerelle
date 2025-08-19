# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::Show::Timeline::Component, type: :component do
  context "when current organization is a collectivity" do
    before { sign_in_as(organization: report.collectivity) }

    context "when report is draft" do
      let(:report) { create(:report) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--current .timeline-step__title", text: "Complétion du formulaire")
        expect(page).to have_selector(".timeline-step__description", text: "En attente de la complétion du formulaire")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Transmission du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement pourra être transmis à la DDFIP une fois le formulaire complété")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Acceptation du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP pourra accepter ou refuser de traiter le signalement lorsqu'il sera transmis")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Réponse de la DDFIP")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP n'a pas encore répondu à propos de ce signalement")
      end
    end

    context "when report is ready" do
      let(:report) { create(:report, :ready) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Formulaire complété")
        expect(page).to have_selector(".timeline-step__description", text: "Le formulaire de signalement a été complété")

        expect(page).to have_selector(".timeline-step--current .timeline-step__title", text: "Transmission du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement est prêt à être transmis à la DDFIP")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Acceptation du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP pourra accepter ou refuser de traiter le signalement lorsqu'il sera transmis")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Réponse de la DDFIP")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP n'a pas encore répondu à propos de ce signalement")
      end
    end

    context "when report is in active transmission" do
      let(:report) { create(:report, :in_active_transmission) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Formulaire complété")
        expect(page).to have_selector(".timeline-step__description", text: "Le formulaire de signalement a été complété")

        expect(page).to have_selector(".timeline-step--current .timeline-step__title", text: "Transmission du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "La transmission du signalement est en attente")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Acceptation du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP pourra accepter ou refuser de traiter le signalement lorsqu'il sera transmis")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Réponse de la DDFIP")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP n'a pas encore répondu à propos de ce signalement")
      end
    end

    context "when report is transmitted or acknowledged" do
      let(:report) { create(:report, %i[transmitted acknowledged].sample) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Formulaire complété")
        expect(page).to have_selector(".timeline-step__description", text: "Le formulaire de signalement a été complété")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement transmis")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été transmis à la DDFIP")

        expect(page).to have_selector(".timeline-step--current .timeline-step__title", text: "Acceptation du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP a reçu le signalement et va le traiter prochainement")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Réponse de la DDFIP")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP n'a pas encore répondu à propos de ce signalement")
      end
    end

    context "when report is accepted, assigned, applicable or inapplicable" do
      let(:report) { create(:report, %i[accepted assigned applicable inapplicable].sample) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Formulaire complété")
        expect(page).to have_selector(".timeline-step__description", text: "Le formulaire de signalement a été complété")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement transmis")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été transmis à la DDFIP")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement accepté")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP a reçu le signalement et accepté son traitement")

        expect(page).to have_selector(".timeline-step--current .timeline-step__title", text: "Réponse de la DDFIP")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP n'a pas encore répondu à propos de ce signalement")
      end
    end

    context "when report is rejected" do
      let(:report) { create(:report, :rejected) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Formulaire complété")
        expect(page).to have_selector(".timeline-step__description", text: "Le formulaire de signalement a été complété")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement transmis")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été transmis à la DDFIP")

        expect(page).to have_selector(".timeline-step--failed .timeline-step__title", text: "Signalement rejeté")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP a rejeté le traitement du signalement")

        expect(page).to have_selector(".timeline-step--failed .timeline-step__title", text: "Réponse de la DDFIP")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP a rejeté le traitement du signalement")
      end
    end

    context "when report is approved" do
      let(:report) { create(:report, :approved) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Formulaire complété")
        expect(page).to have_selector(".timeline-step__description", text: "Le formulaire de signalement a été complété")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement transmis")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été transmis à la DDFIP")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement accepté")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP a reçu le signalement et accepté son traitement")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Réponse de la DDFIP")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP a donné une réponse positive à ce signalement")
      end
    end

    context "when report is canceled" do
      let(:report) { create(:report, :canceled) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Formulaire complété")
        expect(page).to have_selector(".timeline-step__description", text: "Le formulaire de signalement a été complété")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement transmis")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été transmis à la DDFIP")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement accepté")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP a reçu le signalement et accepté son traitement")

        expect(page).to have_selector(".timeline-step--failed .timeline-step__title", text: "Réponse de la DDFIP")
        expect(page).to have_selector(".timeline-step__description", text: "La DDFIP a donné une réponse négative à ce signalement")
      end
    end
  end

  context "when current user is a ddfip admin or dgfip user" do
    before { sign_in_as(:organization_admin, :ddfip) }

    context "when report is transmitted or acknowledged" do
      let(:report) { create(:report, %i[transmitted acknowledged].sample) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--current .timeline-step__title", text: "Acceptation du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement n'a pas encore été accepté ou rejeté")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Assignation à un guichet")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement pourra être assigné à un guichet s'il est accepté")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Résolution du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement pourra être accepté lorsqu'il sera traité par le guichet")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Réponse à la collectivité")
        expect(page).to have_selector(".timeline-step__description", text: "La collectivité n'a pas reçu de retour concernant ce signalement")
      end
    end

    context "when report is accepted" do
      let(:report) { create(:report, :accepted) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Acceptation du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été accepté")

        expect(page).to have_selector(".timeline-step--current .timeline-step__title", text: "Assignation à un guichet")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été accepté et est prêt à être assigné à un guichet")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Résolution du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement pourra être accepté lorsqu'il sera traité par le guichet")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Réponse à la collectivité")
        expect(page).to have_selector(".timeline-step__description", text: "La collectivité n'a pas reçu de retour concernant ce signalement")
      end
    end

    context "when report is rejected" do
      let(:report) { create(:report, :rejected) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--failed .timeline-step__title", text: "Rejet du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été rejeté. Des observations ont pu être transmises à la collectivité")

        expect(page).to have_selector(".timeline-step--failed .timeline-step__title", text: "Assignation à un guichet")
        expect(page).to have_selector(".timeline-step__description", text: "Un signalement rejeté ne peut être assigné à un guichet")

        expect(page).to have_selector(".timeline-step--failed .timeline-step__title", text: "Résolution du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "Aucun guichet n'a pu se prononcer concernant ce signalement")

        expect(page).to have_selector(".timeline-step--failed .timeline-step__title", text: "Réponse à la collectivité")
        expect(page).to have_selector(".timeline-step__description", text: "La collectivité a été notifiée du rejet de ce signalement")
      end
    end

    context "when report is assigned" do
      let(:report) { create(:report, :assigned, :made_for_office) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Acceptation du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été accepté")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Assignation à un guichet")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été assigné au guichet #{report.office.name}")

        expect(page).to have_selector(".timeline-step--current .timeline-step__title", text: "Résolution du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "Le guichet n'a pas encore traité ce signalement")

        expect(page).to have_selector(".timeline-step--pending .timeline-step__title", text: "Réponse à la collectivité")
        expect(page).to have_selector(".timeline-step__description", text: "La collectivité n'a pas reçu de retour concernant ce signalement")
      end
    end

    context "when report is applicable" do
      let(:report) { create(:report, :applicable, :made_for_office) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Acceptation du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été accepté")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Assignation à un guichet")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été assigné au guichet #{report.office.name}")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement validé par le guichet")
        motif = I18n.t("enum.resolution_motif.#{report.form_type}.applicable.#{report.resolution_motif}")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été accepté par le guichet avec le motif « #{motif} »")

        expect(page).to have_selector(".timeline-step--current .timeline-step__title", text: "Réponse à la collectivité")
        expect(page).to have_selector(".timeline-step__description", text: "La réponse du guichet sera transmise à la collectivité une fois confirmée par le référent fiabilisation")
      end
    end

    context "when report is inapplicable" do
      let(:report) { create(:report, :inapplicable, :made_for_office) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Acceptation du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été accepté")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Assignation à un guichet")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été assigné au guichet #{report.office.name}")

        expect(page).to have_selector(".timeline-step--failed .timeline-step__title", text: "Signalement rejeté par le guichet")
        motif = I18n.t("enum.resolution_motif.#{report.form_type}.inapplicable.#{report.resolution_motif}")
        expect(page).to have_selector(".timeline-step__description", text: "Le guichet a refusé le signalement pour le motif « #{motif} »")

        expect(page).to have_selector(".timeline-step--current .timeline-step__title", text: "Réponse à la collectivité")
        expect(page).to have_selector(".timeline-step__description", text: "La réponse du guichet sera transmise à la collectivité une fois confirmée par le référent fiabilisation")
      end
    end

    context "when report is approved" do
      let(:report) { create(:report, :approved, :made_for_office) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Acceptation du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été accepté")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Assignation à un guichet")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été assigné au guichet #{report.office.name}")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Signalement validé par le guichet")
        motif = I18n.t("enum.resolution_motif.#{report.form_type}.applicable.#{report.resolution_motif}")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été accepté par le guichet avec le motif « #{motif} »")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Réponse à la collectivité")
        expect(page).to have_selector(".timeline-step__description", text: "La collectivité a reçu un retour positif")
      end
    end

    context "when report is canceled" do
      let(:report) { create(:report, :canceled, :made_for_office) }

      it do
        render_inline described_class.new(report)
        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Acceptation du signalement")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été accepté")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Assignation à un guichet")
        expect(page).to have_selector(".timeline-step__description", text: "Le signalement a été assigné au guichet #{report.office.name}")

        expect(page).to have_selector(".timeline-step--failed .timeline-step__title", text: "Signalement rejeté par le guichet")
        motif = I18n.t("enum.resolution_motif.#{report.form_type}.inapplicable.#{report.resolution_motif}")
        expect(page).to have_selector(".timeline-step__description", text: "Le guichet a refusé le signalement pour le motif « #{motif} »")

        expect(page).to have_selector(".timeline-step--done .timeline-step__title", text: "Réponse à la collectivité")
        expect(page).to have_selector(".timeline-step__description", text: "La collectivité a reçu un retour négatif")
      end
    end
  end
end
