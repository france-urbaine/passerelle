# frozen_string_literal: true

module API
  class TransmissionsController < ApplicationController
    before_action :authorize!

    resource_description do
      resource_id "transmissions"
      name "Transmission"
      formats ["json"]
      deprecated false
      description <<-DESC
        Une transmission d'un ou plusieurs signalements à une DDFIP
      DESC
    end

    api :POST, "/collectivites/:id/transmissions", "Initialisation d'une transmission"
    description <<-DESC
      Cette ressource permet d'initialiser une nouvelle transmission.

      Une transmission est requise pour transmettre des signalements :
      <br>
      une fois initialisée, vous pouvez y ajouter un ou plusieurs signalements ainsi que des pièces jointes.

      Une fois toutes les données ajoutées, vous pouvez terminer la transmission avec la ressource <code>/complete</code>.
      <br>
      Les DDFIPs ne recevront les signalements qu'une fois la transmission complétée.

      Une transmission est initialisée pour une et une seule collectivité.
      <br>
      Tout les signalements ajoutés dans une transmission sont donc automatiquement associés à cette même collectivité.
      <br>
      Vous pouvez initialiser plusieurs transmissions en parallèle, mais chaque transmission expire aprés 24 heures.

      Pour découvrir l'API en toute sécurité, vous pouvez configurer une application en mode <code>sandbox</code> :
      <br>
      les transmissions initialisées à travers cette applications ne seront jamais transmises aux services de la DGFIP,
      et les signalements ainsi créés ne seront jamais visibles dans Passerelle par toute autre organisation.

      Dans certains cas, votre compte éditeur peut être bridé en mode sandbox par défaut : consultez France Urbaine pour en savoir plus.
      <br>
      Lorsque ce bridage est en place, toute les tranmissions seront initialisée en mode sandbox, quelques soit le mode choisi sur votre application.
    DESC

    see "collectivities#index", "Index des collectivités"
    see "reports#create", "Création d'un signalement"
    see "transmissions#complete", "Validation d'une transmission"

    param :id, String, "UUID de la collectivité", required: true
    param :transmission, Hash, "Attributs relatifs à la transmission" do
      param :sandbox, :bool, "Transmission en mode sandbox", default_value: false
    end

    returns code: 201, desc: "La transmission est initialisée" do
      param :transmission, Hash, "Attributs relatifs à la transmission" do
        property :id, String, desc: "UUID de la nouvelle transmission"
      end
    end

    error 404, "La collectivité n'existe pas ou n'a pas été trouvée."

    def create
      collectivity = find_and_authorize_collectivity
      @transmission = collectivity.transmissions.build
      @transmission.publisher = current_publisher
      @transmission.oauth_application = current_application
      @transmission.sandbox = current_publisher.sandbox? || current_application.sandbox?
      @transmission.save

      respond_with @transmission, status: :created
    end

    api :PUT, "/transmissions/:id/complete", "Validation d'une transmission"
    description <<-DESC
      Cette ressource permet de finaliser une transmission.

      Une fois les signalements ajoutés à une transmission préalablement initialisée,
      vous pouvez valider la transmission :
      <br>
      les signalements seront automatiquement répartis dans des paquets avant d'être remis
      aux DDFIPs concernées qui se réservent le droit d'assigner les paquets aux guichets
      ou de retourner le paquet.

      En réponse, vous obtenez la liste des paquets transmis ainsi que les numéros
      de référence attribués à chaque signalement.
      <br>
      Les numéros de référence peuvent être utilisé dans les échanges entre DDFIPs et collectivités.

      La transmission doit contenir au moins un signalement pour être validée.
    DESC

    see "transmissions#create", "Initialisation d'une transmission"
    see "reports#create", "Créer un signalement"

    returns code: 200, desc: "La transmission est complétée" do
      property :id, String, desc: "UUID de la transmission"
      property :completed_at, DateTime, desc: "Date effective de la transmission"
      property :packages, Array, desc: "Liste des paquets" do
        property :id, String, desc: "ID du paquet"
        property :name, String, desc: "Nom du paquet"
        property :reference, String, desc: "Numéro de référence du paquet"
        property :reports, Array, desc: "Liste des signalements" do
          property :id, String, desc: "ID du signalement"
          property :reference, String, desc: "Numéro de référence du signalement"
        end
      end
    end

    error 400, "Aucun signalement présent dans la tranmission."
    error 404, "La transmission n'existe pas ou n'a pas été trouvée."
    error 403, "La transmission a déjà été complétée."

    def complete
      @transmission = find_and_authorize_transmission

      @service = Transmissions::CompleteService.new(@transmission)
      @result = @service.complete

      @transmission.reload.packages.preload(:reports) if @result.success?

      respond_with @result
    end

    private

    def find_and_authorize_collectivity
      current_publisher.collectivities.find(params[:collectivity_id]).tap do |collectivity|
        authorize! collectivity, to: :read?
      end
    end

    def find_and_authorize_transmission
      current_application.transmissions.find(params[:id]).tap do |transmission|
        authorize! transmission, to: :read?
        forbidden! t(".already_completed")    if transmission.completed?
        bad_request! t(".reports_empty")      if transmission.reports.none?
        bad_request! t(".reports_incomplete") if transmission.reports.incomplete.any?
        authorize! transmission, to: :complete?
      end
    end
  end
end
