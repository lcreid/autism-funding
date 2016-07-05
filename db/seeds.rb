# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
provs = {\
    "AB" => "Alberta"\
  , "BC" => "British Columbia"\
  , "MB" => "Manitoba"\
  , "NB" => "New Brunswick"\
  , "NF" => "Newfoundland"\
  , "NS" => "Nova Scotia"\
  , "NT" => "Northwest Territories"\
  , "NU" => "Nunavut"\
  , "ON" => "Ontario"\
  , "PE" => "Prince Edward Island"\
  , "QC" => "Quebec"\
  , "SK" => "Saskatchewan"\
  , "YT" => "Yukon"\
}

provs.keys.each do |p|
  rec = ProvinceCode.find_by prov_code: p
  if rec.nil?
    rec = ProvinceCode.new(prov_code: p)
  end
  rec.province_name = provs[p]
  if p == "BC"
    rec.not_supported = nil
  else
    rec.not_supported = 'Y'
  end
  rec.save
end
