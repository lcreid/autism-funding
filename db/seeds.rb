# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
##-- Original Seeds as Written By Larry -------------------------------------------
# ProvinceCode.new([
#                   { province_code: 'AB', province_name: 'Alberta' },
#                   { province_code: 'BC', province_name: 'British Columbia' }
#                 ])
#
# Form.new(province_code: ProvinceCode.find_by(province_code: 'BC'),
#         form_name: 'Request to Pay',
#         form_description: 'Used to authorize payment to a service provider.',
#         file_name: File.join(Rails.root, 'app/assets/pdf_forms/cf_0925.pdf'),
#         class_name: 'Cf0925')
##-------------- end original Seeds as Written by Larry -------------------------
## Ensure the province_codes table is intialized correctly
##
##  Define the set of provinces (states) that should exist in the province_codes
##    table, along with the province full name and not_supported status
provs = {\
  "AB" => { "province_name" => "Alberta", "not_supported" => "Y" }\
  , "BC" => { "province_name" => "British Columbia", "not_supported" => nil }\
  , "MB" => { "province_name" => "Manitoba", "not_supported" => "Y" }\
  , "NB" => { "province_name" => "New Brunswick", "not_supported" => "Y" }\
  , "NF" => { "province_name" => "Newfoundland", "not_supported" => "Y" }\
  , "NS" => { "province_name" => "Nova Scotia", "not_supported" => "Y" }\
  , "NT" => { "province_name" => "Northwest Territories", "not_supported" => "Y" }\
  , "NU" => { "province_name" => "Nunavut", "not_supported" => "Y" }\
  , "ON" => { "province_name" => "Ontario", "not_supported" => "Y" }\
  , "PE" => { "province_name" => "Prince Edward Island", "not_supported" => "Y" }\
  , "QC" => { "province_name" => "Quebec", "not_supported" => "Y" }\
  , "SK" => { "province_name" => "Saskatchewan", "not_supported" => "Y" }\
  , "YT" => { "province_name" => "Yukon", "not_supported" => "Y" }\
}
## Ensure each province is found in the table and update the name and supported status
provs.keys.each do |p|
  rec = ProvinceCode.find_by province_code: p
  rec = ProvinceCode.new(province_code: p) if rec.nil?
  rec.province_name = provs[p]["province_name"]
  rec.not_supported = provs[p]["not_supported"]
  rec.save
end

## Initilize forms
frms = {\
  "Cf0925" => {\
    "file_name" => File.join(Rails.root, "app/assets/pdf_forms/cf_0925.pdf"),\
    "form_name" => "Request to Pay",\
    "form_description" => "Used to authorize payment to a service provider.",\
    "province_code" => ProvinceCode.find_by(province_code: "BC")\
  }\
}

## Ensure each form is found in the table and update the data
frms.keys.each do |c|
  rec = Form.find_by class_name: c
  rec = Form.new(class_name: c) if rec.nil?
  rec.file_name = frms[c]["file_name"]
  rec.form_name = frms[c]["form_name"]
  rec.form_description = frms[c]["form_description"]
  rec.province_code = frms[c]["province_code"]
  rec.save
end
