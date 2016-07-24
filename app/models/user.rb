class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :addresses
  # FIXME: the next line has to change every time we add another form.
  #   There should be a btter way.
  has_many :forms, through: :funded_people, source: :cf0925s
  has_many :funded_people
  has_many :phone_numbers

  def my_name
    my_name = "#{name_first} #{name_middle}".strip
    my_name = "#{my_name} #{name_last}".strip
    my_name = email if my_name == ''
    my_name
  end
end
