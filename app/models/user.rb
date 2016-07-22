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

  def my_address
    if id.nil?
      ret_obj = nil
    elsif addresses.size == 0
      ret_obj = Address.create(user_id: id)
      addresses.reload   #refreshes cache
    else
      ret_obj = addresses[0]
    end
    return ret_obj
  end

  def my_home_phone
    return my_phone "Home"
  end
  def my_work_phone
    return my_phone "Work"
  end


  private
    def my_phone the_type
      obj_phone = phone_numbers.find_by( phone_type: the_type)
      if id.nil?
        ret_obj = nil
      elsif obj_phone.nil?
        ret_obj = PhoneNumber.create(user_id: id, phone_type: the_type)
        phone_numbers.reload   #refreshes cache
      else
        ret_obj = obj_phone
      end
      return ret_obj
    end

end
