class ProvinceCode < ApplicationRecord
  has_many :users
  has_many :forms
end
