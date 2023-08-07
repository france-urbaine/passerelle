# frozen_string_literal: true

module Views
  module Reports
    class ShowComponent
      class SituationMajic < self
        def situation_adresse
          if @report.situation_adresse?
            @report.situation_adresse
          elsif @report.situation_libelle_voie?
            [
              @report.situation_numero_voie,
              @report.situation_indice_repetition,
              @report.situation_libelle_voie
            ].join(" ").squish
          end
        end

        def situation_porte
          value = []
          value << "Bâtiment #{@report.situation_numero_batiment}" if @report.situation_numero_batiment?
          value << "Escalier #{@report.situation_numero_escalier}" if @report.situation_numero_escalier?
          value << "Niveau #{@report.situation_numero_niveau}" if @report.situation_numero_niveau?
          value << "Porte #{@report.situation_numero_porte}" if @report.situation_numero_porte?
          value.join(" ")
        end

        def situation_numero_ordre_porte
          @report.situation_numero_ordre_porte&.rjust(3, "0")
        end
      end
    end
  end
end
