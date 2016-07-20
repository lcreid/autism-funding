# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
ProvinceCode.new([
                   { province_code: 'AB', province_name: 'Alberta' },
                   { province_code: 'BC', province_name: 'British Columbia' }
                 ])

Form.new(province_code: ProvinceCode.find_by(province_code: 'BC'),
         form_name: 'Request to Pay',
         form_description: 'Used to authorize payment to a service provider.',
         file_name: File.join(Rails.root, 'app/assets/pdf_forms/cf_0925.pdf'))
