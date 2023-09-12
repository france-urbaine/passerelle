# frozen_string_literal: true

FactoryBot.define do
  after(:stub) do |object|
    # FactoryBot doesn't set up primary key on stubbed records
    # because we use UUID everywhere instead of integers.
    #
    object.id ||= SecureRandom.uuid
  end

  before(:create) do |object, evaluator|
    # Skip uniqueness validations to perform less SQL queries.
    #
    # The time saved is not significant but it reduces logs noise
    # by removing duplicate SQL queries.
    #
    # Uniqueness must be handled in factory definitions using various ways:
    #   - by using sequences:
    #       sequence(:email) { |n| "person#{n}@example.com" }
    #
    #   - by using unique fake data:
    #       siren { Faker::Company.unique.french_siren_number }
    #
    #   - or by verifing uniqueness until a unique value is found
    #       name do
    #         loop do
    #           value = Faker::Address.city
    #           break value unless Model.exists?(name: value)
    #         end
    #       end
    #
    # Finally, uniqueness should be ensured at database level by using unique
    # constraints or unique indexes.
    #
    # When needed, you can always ovveride this behavior by passing a
    # `skip_uniqueness_validation` attribute.
    #
    object.skip_uniqueness_validation = true unless evaluator.__override_names__.include?(:skip_uniqueness_validation)
  end

  after(:create) do |object, evaluator|
    # Reset the skip_uniqueness_validation after being created.
    #
    object.skip_uniqueness_validation = false unless evaluator.__override_names__.include?(:skip_uniqueness_validation)
  end
end

# Unsubscribe notifications to avoid duplicate message in console
# after reloading it with `reload!`
#
ActiveSupport::Notifications.unsubscribe("factory_bot.run_factory")
ActiveSupport::Notifications.subscribe("factory_bot.run_factory") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  Rails.logger.debug do
    title         = "FactoryBot"
    duration      = event.duration.round(1)
    factory_name  = event.payload[:name]
    strategy_name = event.payload[:strategy]

    "  [#{title}] (#{duration}ms) #{strategy_name} #{factory_name}"
  end
end
