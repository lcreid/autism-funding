class User < ApplicationRecord
  include Preferences
  include AddressValidators

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :addresses, inverse_of: :user, dependent: :destroy
  belongs_to :province_code, optional: true

  accepts_nested_attributes_for :addresses, allow_destroy: true

  # FIXME: the next line has to change every time we add another form.
  #   There should be a btter way.
  has_many :forms,
           -> { order(created_at: :desc) },
           through: :funded_people,
           source: :cf0925s

  has_many :funded_people,
           -> { order(:name_first) },
           inverse_of: :user,
           dependent: :destroy
  accepts_nested_attributes_for :funded_people,
                                allow_destroy: true,
                                reject_if: :all_blank
  has_many :phone_numbers, inverse_of: :user, dependent: :destroy
  accepts_nested_attributes_for :phone_numbers,
                                reject_if: proc { |attributes|
                                  attributes[:phone_number].blank?
                                }

  has_many :cf0925s, through: :funded_people
  has_many :invoices, through: :funded_people

  validate :validate_phone_numbers

  validate :validate_at_least_one_phone_number, on: :printable

  validates :address,
            :city,
            :postal_code,
            presence: true,
            on: :printable
  # TODO: Validate postal code?

  # TODO: We had to move this validates to this location to make tests run green
  # but we don't understand why
  validates :name_first,
            :name_last,
            presence: true,
            on: :printable

  #-- Public Methods -------------------------------------------------------------
  #-- pseduo-attribute address -------------------
  # Get Address for User
  def address
    address_record.address_line_1
  end

  # Set Address for user
  def address=(val)
    address_record.address_line_1 = val
  end

  # Returns true if the address is in the province of British Columbia
  def bc_resident?
    address_record.get_province_code == 'BC'
  end

  # Returns true if the user is able to create a new RTP form
  def can_create_new_rtp?
    bc_resident? && !funded_people.empty?
  end

  # Returns true if the user is able to navigate to the home page
  def can_see_my_home?
    ret = !missing_key_info?
    cnt_items = 0
    # Check all funded people are valid and get count of invoices/forms
    # puts "#{__LINE__}: state of ret #{ret}"
    if ret
      all_valid = true
      funded_people.each do |fp|
        cnt_items += fp.invoices.size
        cnt_items += fp.cf0925s.size
        unless fp.valid? || fp.is_blank?
          # puts "#{fp.id}: #{fp.my_name} #{fp.birthdate}"
          all_valid = false
        end
      end
      ret = all_valid
    end
    # puts "#{__LINE__}: state of ret #{ret}"
    ret = false if address_record.get_province_code != 'BC' && (cnt_items < 1)
    # puts "#{__LINE__}: state of ret #{ret}"
    ret
    end

  #-- pseduo-attribute city -------------------
  # Get City for User
  def city
    address_record.city
  end

  # Set City for User
  def city=(val)
    address_record.city = val
  end

  #-- pseduo-attribute home_phone-number -------------
  # Get Home Phone Number for User
  def home_phone_number
    phone_record('Home').phone_number
  end

  # Set Home Phone Number for User
  def home_phone_number=(val)
    phone_record('Home').phone_number = val
  end

  # Returns true if the user has not defined enough information to get access to
  # My Home page (and the functionality of the application)
  # User must have entered at least one non-blank funded_person and a province code
  def missing_key_info?
    # Need to check if there are at least 1 non-blank, valid funded_people
    ret = true
    # puts "funded_people size: #{funded_people.size}"
    funded_people.each do |fp|
      # puts "mising_key_info? #{__LINE__}: #{fp.inspect}"
      # puts "missing_key_info? is_blank? #{fp.is_blank?} valid? #{fp.valid?}"
      # puts "#{fp.errors.full_messages}" unless fp.valid?
      next if fp.is_blank? || !fp.valid?
      # puts 'mising_key_info? got false on funded_person'
      ret = false
      break
    end
    # puts "mising_key_info? #{__LINE__}: got #{ret} after funded_people"
    ret ||= province_code_id.nil?
    # puts "mising_key_info? #{__LINE__}: got #{ret} on province_code_id nil"
    ret ||= address_record.get_province_code.empty?
    # puts "mising_key_info? #{__LINE__}: got #{ret} on get_province_code empty"
    ret
  end

  # Returns a formatted full name for user.  If no name provided, the email address
  # is returned
  def my_name
    my_name = "#{name_first} #{name_middle}".strip
    my_name = "#{my_name} #{name_last}".strip
    my_name = email if my_name == ''
    my_name
  end

  def open_panel
    preference(:open_panel_child_id, nil)
  end

  #-- pseduo-attribute postal_code -------------------
  # Get Postal Code for User
  def postal_code
    address_record.postal_code
  end

  # Set Postal Code for User
  def postal_code=(val)
    address_record.postal_code = val
  end

  # Retreive the value for a preference
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

  # Returns true if the user has all required information to print out a RTP form
  def printable?
    user_printable = valid?(:printable)
    # puts "user.printable? #{errors.full_messages}" unless user_printable
    # puts "I have #{addresses.size} addresses"
    address_printable = address_record.printable?
    # TODO: Validate phone numbers.
    user_printable && address_printable
  end

  #-- pseduo-attribute province_code_id --------------
  # Get province_code_id for User
  def province_code_id
    address_record.province_code_id
  end

  # Get province_code_id for User
  def province_code_id=(val)
    address_record.province_code_id = val
  end

  # Set the child ID of the open panel, since only one can be open
  def set_open_panel(child_id, state)
    set_preference(open_panel_child_id: state.to_sym == :open ? child_id : nil)
  end

  def set_preference(hash)
    # logger.debug { "Set preference new hash: #{hash}" }
    self.preferences = json(preferences).merge(hash).to_json
    # logger.debug { "Set preference preferences: #{preferences}" }
    save
  end

  #-- pseduo-attribute work_phone_extension -------------------
  # Get Work Phone Extension for User
  def work_phone_extension
    phone_record('Work').phone_extension
  end

  # Set Work Phone Number for User
  def work_phone_extension=(val)
    phone_record('Work').phone_extension = val
  end

  #-- pseduo-attribute work_phone_number -------------------
  # Get Work Phone Number for User
  def work_phone_number
    phone_record('Work').phone_number
  end

  # Set Work Phone Number for User
  def work_phone_number=(val)
    phone_record('Work').phone_number = val
  end

  # Attach an error message to the symbol :phone_numbers if neither home
  # nor work phone provided.
  # I struggled for a while to attach the messages to the phone numbers.
  # In doing so, I realized (read) that that approach wasn't going to work,
  # because when you validate the phone number itself, you wipe out the
  # previous error messages.
  def validate_at_least_one_phone_number
    if work_phone_number.blank? && home_phone_number.blank?
      errors.add(:phone_numbers, 'must provide at least one phone number')
    end
  end

  # validate phones numbers (work and home) by checking for errors in the related
  # Phone table.  This will associate errors with the appropriate pseduo-attribute
  def validate_phone_numbers
    # puts 'Validating phone numbers'
    phone_record('Work').validate
    phone_record('Work').errors[:phone_number].each do |e|
      # puts "Error in work #{e}"
      errors.add(:work_phone_number, e)
    end
    phone_record('Work').errors[:phone_extension].each do |e|
      # puts "Error in extension #{e}"
      errors.add(:work_phone_extension, e)
    end
    phone_record('Home').validate
    phone_record('Home').errors[:phone_number].each do |e|
      # puts "Error in home #{e}"
      errors.add(:home_phone_number, e)
    end
  end

  #### private methods ###########################################################
  private

  def address_record
    addresses.build unless addresses[0]
    addresses[0]
  end

  def phone_record(type)
    phone_numbers.find { |x| x.phone_type == type } || phone_numbers.build(phone_type: type)
  end
end
