# frozen_string_literal: true

module AuthorizedLink
  class Component < ApplicationViewComponent
    def initialize(resource, href = nil, namespace: nil, parent: nil, **options)
      @resource  = resource
      @href      = href
      @namespace = namespace
      @parent    = parent
      @options   = options
      super()
    end

    def call
      return unless @resource

      if @resource.discarded?
        dicarded_label
      elsif @resource && allowed?
        link
      else
        label
      end
    end

    def label
      content ||
        case @resource
        when Package, Report
          @resource.reference
        else
          @resource&.name
        end
    end

    def dicarded_label
      tag.div(class: "text-disabled") do
        case @resource
        when DDFIP, Publisher, Collectivity
          "#{label} (organisation supprimée)"
        when Office
          "#{label} (guichet supprimé)"
        when User
          "#{label} (utilisateur supprimé)"
        when Package
          "#{label} (paquet supprimé)"
        else
          label
        end
      end
    end

    def link
      helpers.link_to(label, href, data: { turbo_frame: "_top" }, **@options)
    end

    def allowed?
      case [@namespace, @parent, @resource]
      in [:organization, Collectivity, User]
        allowed_to?(:show?, @resource, namespace: ::Organization::Collectivities, context: { collectivity: @parent })

      in [*, Commune] | [*, EPCI] | [*, Departement] | [*, Region]
        allowed_to?(:show?, @resource, namespace: ::Territories)

      in [*, Publisher] | [*, DDFIP] | [*, DGFIP] | [:territories, *]
        allowed_to?(:show?, @resource, namespace: ::Admin)

      in [*, User] | [*, Office] | [*, Collectivity]
        namespace = (@namespace || :organization).to_s.classify.constantize
        allowed_to?(:show?, @resource, namespace: namespace)

      else
        allowed_to?(:show?, @resource)
      end
    end

    def href
      @href ||=
        case [@namespace, @parent, @resource]
        in [:organization, Collectivity, User]
          polymorphic_path([@namespace, @parent, @resource])

        in [*, Commune] | [*, EPCI] | [*, Departement] | [*, Region]
          polymorphic_path([:territories, @resource])

        in [*, Publisher] | [*, DDFIP] | [*, DGFIP] | [:territories, *]
          polymorphic_path([:admin, @resource])

        in [*, User] | [*, Office] | [*, Collectivity]
          polymorphic_path([@namespace || :organization, @resource])

        else
          polymorphic_path([@resource])
        end
    end
  end
end
