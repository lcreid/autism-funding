class User < ApplicationRecord
  include Preferences
  include AddressValidators

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :addresses, inverse_of: :user
  belongs_to :province_code, optional: true

  accepts_nested_attributes_for :addresses, allow_destroy: true

  # FIXME: the next line has to change every time we add another form.
  #   There should be a btter way.
  has_many :forms, through: :funded_people, source: :cf0925s
  has_many :funded_people, inverse_of: :user
  accepts_nested_attributes_for :funded_people,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :phone_numbers, inverse_of: :user
  accepts_nested_attributes_for :phone_numbers,
                                reject_if: proc { |attributes|
                                  attributes[:phone_number].blank?
                                }

  validates :name_first,
            :name_last,
            presence: true,
            on: :printable

  validate :validate_phone_numbers

  # This following doesn't seem to work.
  # validates :my_work_phone,
  #           presence: true,
  #           on: :printable,
  #           unless: ->(x) { x.my_home_phone.present? }
  #
  # validates :my_home_phone,
  #           presence: true,
  #           on: :printable,
  #           unless: ->(x) { x.my_work_phone.present? }
  validate :at_least_one_phone_number, on: :printable

  validates :address,
            :city,
            :postal_code,
            presence: true,
            on: :printable
  # TODO: Validate postal code?

#-- Public Methods -------------------------------------------------------------
# Returns true if the address is in the province of British Columbia
def bc_resident?
  address_record.get_province_code == 'BC'
end

# Returns true if the user is able to navigate to the home page
def can_see_my_home?
  ret = ! self.missing_key_info?
  cnt_items = 0
  # Check all funded people are valid and get count of invoices/forms
# puts "#{__LINE__}: state of ret #{ret}"
  if ret
    all_valid = true
    self.funded_people.each do |fp|
       cnt_items += fp.invoices.size
       cnt_items += fp.cf0925s.size
       unless fp.valid? || fp.is_blank?
         puts "#{fp.id}: #{fp.my_name} #{fp.birthdate}"
         all_valid = false
       end
     end
     ret = all_valid
  end
# puts "#{__LINE__}: state of ret #{ret}"
  if ( address_record.get_province_code ) != 'BC' && ( cnt_items < 1 )
     ret = false
  end
# puts "#{__LINE__}: state of ret #{ret}"
  return ret
end



# Returns true if the user has not defined enough information to get access to
# My Home page (and the functionality of the application)
# User must have entered at least one non-blank funded_person and a province code
def missing_key_info?
  # Need to check if there are at least 1 non-blank, valid funded_people
  ret = true
  funded_people.each do |fp|
    unless fp.is_blank? || (! fp.valid?)
      ret = false
      break
    end
  end
  ret = ret || province_code_id.nil?
  ret = ret || address_record.get_province_code.empty?
  return ret
end

# Returns true if the user has all required information to print out a RTP form
def printable?
  user_printable = valid?(:printable)
  # puts "user.printable? #{errors.full_messages}" unless user_printable
  # puts "I have #{addresses.size} addresses"
  address_printable = address_record.printable?
  # TODO: Validate phone numbers.
  user_printable && address_printable
end



  # Get Address for User
  def address
    address_record.address_line_1
  end

  # Set Address for user
  def address=(val)
    address_record.address_line_1 = val
  end

  # Get City for User
  def city
    address_record.city
  end
  # Set City for User
  def city=(val)
    address_record.city = val
  end

  # Get province_code_id for User
  def province_code_id
    address_record.province_code_id
  end
  # Get province_code_id for User
  def province_code_id=(val)
    address_record.province_code_id = val
  end


  # Get Postal Code for User
  def postal_code
    address_record.postal_code
  end

  # Set Postal Code for User
  def postal_code=(val)
    address_record.postal_code = val
  end

  # Get Home Phone Number for User
  def home_phone_number
    phone_record('Home').phone_number
  end
  # Set Home Phone Number for User
  def home_phone_number=(val)
    phone_record('Home').phone_number = val
  end

  # Get Work Phone Number for User
  def work_phone_number
    phone_record('Work').phone_number
  end
  # Set Work Phone Number for User
  def work_phone_number=(val)
    phone_record('Work').phone_number = val
  end

  # Get Work Phone Extension for User
  def work_phone_extension
    phone_record('Work').phone_extension
  end
  # Set Work Phone Number for User
  def work_phone_extension=(val)
    phone_record('Work').phone_extension = val
  end

  def validate_phone_numbers
    phone_record('Work').validate
    phone_record('Work').errors[:phone_number].each do |e|
      errors.add(:work_phone_number,e)
    end
    phone_record('Work').errors[:phone_extension].each do |e|
      errors.add(:work_phone_extension,e)
    end
    phone_record('Home').validate
    phone_record('Home').errors[:phone_number].each do |e|
      errors.add(:home_phone_number,e)
    end

#    phones.each do |p|
#      p.validate
#      p.error
#    end
#    if !home_phone? && !work_phone?
#      errors.add(:phone_numbers, 'must provide at least one phone number')
#    end
  end


  ##
  # By conention, the first address is the address we use.
  # FIXME: This may be redundant after merging Phil's code.
  # def address
  #   addresses[0] if addresses.present?
  # end

  ##
  # Attach an error message to the symbol :phone_numbers if neither home
  # nor work phone provided.
  # I struggled for a while to attach the messages to the phone numbers.
  # In doing so, I realized (read) that that approach wasn't going to work,
  # because when you validate the phone number itself, you wipe out the
  # previous error messages.
  def at_least_one_phone_number
    if !home_phone? && !work_phone?
      errors.add(:phone_numbers, 'must provide at least one phone number')
    end
  end


  ##
  # Return true if the user has once acknowledged the notification
  # that the forms are only for residents of BC.
  def bc_warning_acknowledgement?
    preference(:bc_warning_acknowledgement, false)
  end

  def can_create_new_rtp?
    bc_resident? && !funded_people.empty?
  end


  def home_phone
    phone 'Home'
  end

  def home_phone?
    !home_phone.nil? && home_phone.phone_number.present?
  end

  def my_home_phone
    my_phone 'Home'
  end

  def my_name
    my_name = "#{name_first} #{name_middle}".strip
    my_name = "#{my_name} #{name_last}".strip
    my_name = email if my_name == ''
    my_name
  end

  def my_work_phone
    my_phone 'Work'
  end

  def open_panel
    preference(:open_panel_child_id, nil)
  end

  def phone(phone_type)
    phone_numbers.select { |x| x.phone_type == phone_type }.first
  end

  def preference(key, default)
    # logger.debug { "Preference args: #{key}(#{key.class})" }
    # logger.debug { "Preferences: #{preferences}" }
    pref_hash = json(preferences)
    # logger.debug { "Preferences hash: #{pref_hash}" }
    value = pref_hash && pref_hash[key.to_s]
    # logger.debug { "Preferences value before default: #{value}" }
    value ||= default
    # logger.debug { "Preferences value: #{value}" }
    value
  end


  def set_bc_warning_acknowledgement(state)
    set_preference(bc_warning_acknowledgement: state)
  end

  ##
  # Set the child ID of the open panel, since only one can be open
  def set_open_panel(child_id)
    set_preference(open_panel_child_id: child_id)
  end

  def set_preference(hash)
    # logger.debug { "Set preference new hash: #{hash}" }
    self.preferences = json(preferences).merge(hash).to_json
    # logger.debug { "Set preference preferences: #{preferences}" }
    save
  end

  def work_phone
    phone 'Work'
  end

  def work_phone?
    !work_phone.nil? && work_phone.phone_number.present?
  end

  #### private methods ###########################################################
  private

  def address_record
    unless addresses[0]
      addresses.build
    end
    addresses[0]
  end

  def phone_record(type)
    phone_numbers.find { |x| x.phone_type == type } || phone_numbers.build(phone_type: type)
  end

  def my_phone(the_type)
    # obj_phone = phone_numbers.find(phone_type: the_type)
    obj_phone = phone_numbers.find_by(phone_type: the_type)

    ret_obj = nil
    self.phone_numbers.each do |pn|
      if pn.phone_type == the_type
        ret_obj = pn
      end
    end

    if obj_phone.nil? && self.id.nil?
      ret_obj = phone_numbers.build
      ret_obj.phone_type = the_type
    elsif obj_phone.nil?
      ret_obj = PhoneNumber.create(user_id: id, phone_type: the_type)
      phone_numbers.reload # refreshes cache
#    else
#      ret_obj = obj_phone
    end
    ret_obj
  end
end
