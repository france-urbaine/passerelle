# frozen_string_literal: true

module Reports
  class DecorateService < SimpleDelegator
    alias report __getobj__

    def situation_adresse
      if report.situation_adresse?
        report.situation_adresse
      elsif situation_libelle_voie?
        [
          situation_numero_voie,
          situation_indice_repetition,
          situation_libelle_voie
        ].join(" ").squish
      end
    end

    def situation_adresse?
      super || situation_libelle_voie?
    end

    def situation_porte
      value = []
      value << "Bâtiment #{situation_numero_batiment}" if situation_numero_batiment?
      value << "Escalier #{situation_numero_escalier}" if situation_numero_escalier?
      value << "Niveau #{situation_numero_niveau}" if situation_numero_niveau?
      value << "Porte #{situation_numero_porte}" if situation_numero_porte?
      value.join(" ")
    end

    def situation_numero_ordre_porte
      super&.rjust(3, "0")
    end

    def situation_porte?
      situation_numero_batiment? || situation_numero_escalier? || situation_numero_niveau? || situation_numero_porte?
    end

    def situation_affectation
      I18n.t(super, scope: "enum.affectation") if situation_affectation?
    end

    def situation_nature
      I18n.t(super, scope: "enum.nature_local") if situation_nature?
    end

    def proposition_nature
      I18n.t(super, scope: "enum.nature_local") if proposition_nature?
    end

    def situation_categorie
      return unless situation_categorie?

      case report.action
      when "evaluation_hab", "occupation_hab"
        I18n.t(super, scope: "enum.categorie_habitation")
      else
        I18n.t(super, scope: "enum.categorie_economique")
      end
    end

    def proposition_categorie
      return unless proposition_categorie?

      case report.action
      when "evaluation_hab", "occupation_hab"
        I18n.t(super, scope: "enum.categorie_habitation")
      else
        I18n.t(super, scope: "enum.categorie_economique")
      end
    end

    def situation_coefficient_entretien
      I18n.t(super, scope: "enum.coefficient_entretien") if situation_coefficient_entretien?
    end

    def situation_coefficient_situation_generale
      I18n.t(super, scope: "enum.coefficient_situation") if situation_coefficient_situation_generale?
    end

    def situation_coefficient_situation_particuliere
      I18n.t(super, scope: "enum.coefficient_situation") if situation_coefficient_situation_particuliere?
    end

    def proposition_coefficient_entretien
      I18n.t(super, scope: "enum.coefficient_entretien") if proposition_coefficient_entretien?
    end

    def proposition_coefficient_situation_generale
      I18n.t(super, scope: "enum.coefficient_situation") if proposition_coefficient_situation_generale?
    end

    def proposition_coefficient_situation_particuliere
      I18n.t(super, scope: "enum.coefficient_situation") if proposition_coefficient_situation_particuliere?
    end
  end
end
