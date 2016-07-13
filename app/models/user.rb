class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :addresses
  has_many :funded_people
  has_many :phone_numbers

  def my_name
    my_name ="#{name_first} #{name_middle}".strip
    my_name ="#{my_name} #{name_last}".strip
    if my_name == ""
      my_name = email
    end
    return my_name
  end

end
