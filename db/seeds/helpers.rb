# frozen_string_literal: true

LOG_PREFIX = "\e[34m[ db/seed ]\e[0m"

def log(message)
  puts "#{LOG_PREFIX} #{message}"
end

def gets
  print "#{LOG_PREFIX} > "
  result = $stdin.gets(chomp: true)
  log ""
  result
end

def parse_csv(path)
  require "csv"
  path = Rails.root.join(path)
  CSV.open(path, "r", headers: true, col_sep: ";").map(&:to_h)
end

def parse_collectivities(data)
  publishers = Publisher.pluck(:name, :id).to_h

  data.map do |hash|
    publisher = publishers[hash.delete(:publisher)]
    territory =
      case hash
      in commune: String then Commune.find_by!(name: hash.delete(:commune))
      in epci: String    then EPCI.find_by!(name: hash.delete(:epci))
      end

    hash[:publisher_id]   = publisher
    hash[:territory_type] = territory.class.name
    hash[:territory_id]   = territory.id
    hash[:name]           = territory.qualified_name
    hash
  end
end

def parse_users(data)
  organizations = {}
    .merge(Collectivity.all.index_by(&:name))
    .merge(Publisher.all.index_by(&:name))
    .merge(DDFIP.all.index_by(&:name))

  data.map do |hash|
    organization = organizations[hash.delete(:organization)]

    hash[:organization_type] = organization.class.name
    hash[:organization_id]   = organization.id

    hash[:first_name] ||= Faker::Name.first_name
    hash[:last_name]  ||= Faker::Name.last_name
    hash[:name]         = hash.values_at(:first_name, :last_name).join(" ").strip

    hash[:confirmed_at] = hash.delete(:confirmed) ? Time.current : nil
    hash
  end
end

def parse_offices(data)
  ddfips = DDFIP.pluck(:name, :id).to_h

  data.map do |hash|
    hash[:ddfip_id] = ddfips[hash.delete(:ddfip)]
    hash
  end
end

def parse_office_users(data)
  offices = Office.pluck(:name, :id).to_h
  users   = User.pluck(:email, :id).to_h

  data.map do |hash|
    hash[:office_id] = offices[hash.delete(:office)]
    hash[:user_id]   = users[hash.delete(:user)]
    hash
  end
end

def parse_office_communes(data)
  offices      = Office.pluck(:name, :id).to_h
  epcis        = Hash.new { |hash, name| hash[name] = EPCI.find_by!(name: name).communes.pluck(:code_insee) }
  departements = Hash.new { |hash, name| hash[name] = Departement.find_by!(name: name).communes.pluck(:code_insee) }

  data.flat_map do |hash|
    office_id   = offices[hash.delete(:office)]
    codes_insee =
      case hash
      in epci: String        then epcis[hash.delete(:epci)]
      in departement: String then departements[hash.delete(:departement)]
      end

    codes_insee.map do |code|
      { office_id: office_id, code_insee: code }
    end
  end
end
