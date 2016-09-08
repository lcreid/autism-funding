class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :addresses, inverse_of: :user
  accepts_nested_attributes_for :addresses

  # FIXME: the next line has to change every time we add another form.
  #   There should be a btter way.
  has_many :forms, through: :funded_people, source: :cf0925s
  has_many :funded_people, inverse_of: :user
  accepts_nested_attributes_for :funded_people, allow_destroy: true, reject_if: :all_blank
  has_many :phone_numbers, inverse_of: :user
  accepts_nested_attributes_for :phone_numbers, reject_if: proc { |attributes| attributes[:phone_number].blank? }

  def my_name
    my_name = "#{name_first} #{name_middle}".strip
    my_name = "#{my_name} #{name_last}".strip
    my_name = email if my_name == ''
    my_name
  end

  def my_address
    if id.nil?
      ret_obj = nil
    elsif addresses.empty?
      ret_obj = Address.create(user_id: id)
      addresses.reload # refreshes cache
    else
      ret_obj = addresses[0]
    end
    ret_obj
  end

  def my_home_phone
    my_phone 'Home'
  end

  def my_work_phone
    my_phone 'Work'
  end

  def supported?
    my_address.province_code &&
      !(my_address.province_code.not_supported == 'Y')
  end

  private

  def my_phone(the_type)
    obj_phone = phone_numbers.find_by(phone_type: the_type)
    if id.nil?
      ret_obj = nil
    elsif obj_phone.nil?
      ret_obj = PhoneNumber.create(user_id: id, phone_type: the_type)
      phone_numbers.reload # refreshes cache
    else
      ret_obj = obj_phone
    end
    ret_obj
  end
end
