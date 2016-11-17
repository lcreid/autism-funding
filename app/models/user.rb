class User < ApplicationRecord
  include Preferences

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :addresses, inverse_of: :user
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

  ##
  # By conention, the first address is the address we use.
  # FIXME: This may be redundant after merging Phil's code.
  def address
    addresses[0] if addresses.present?
  end

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

  def bc_resident?
    my_address.get_province_code == 'BC'
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

  def can_see_my_home?
    ret = !missing_key_info?
    if ret && my_address.get_province_code != 'BC'
      cnt = 0
      funded_people.each do |fp|
        cnt += fp.invoices.size
        cnt += fp.cf0925s.size
      end
      ret = cnt > 0
    end
    ret
  end

  def home_phone
    phone 'Home'
  end

  def home_phone?
    !home_phone.nil? && home_phone.phone_number.present?
  end

  def missing_key_info?
    ret = funded_people.empty?
    ret ||= my_address.nil?
    ret ||= my_address.get_province_code.empty?
    ret
  end

  def my_address
    ##########################
    # if id.nil?
    #  ret_obj = nil
    # elsif addresses.empty?
    #  Address.create(user_id: id)
    #  addresses.reload # refreshes cache
    #  ret_obj = addresses[0]
    # else
    #  ret_obj = addresses[0]
    # end
    # ret_obj
    #######################################
    if id.nil? && addresses.empty?
      addresses.build
    elsif addresses.empty?
      Address.create(user_id: id)
      addresses.reload
    end
    addresses[0]
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

  def printable?
    user_printable = valid?(:printable)
    # puts "user.printable? #{errors.full_messages}" unless user_printable
    # puts "I have #{addresses.size} addresses"
    # pp my_address
    address_printable = my_address.printable?
    # puts("my_address.printable? #{my_address.errors.full_messages}") unless
    # TODO: Validate phone numbers.
    user_printable && address_printable
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

  def supported?
    my_address.province_code &&
      !(my_address.province_code.not_supported == 'Y')
  end

  def work_phone
    phone 'Work'
  end

  def work_phone?
    !work_phone.nil? && work_phone.phone_number.present?
  end

  #### private methods ###########################################################
  private

  def my_phone(the_type)
    # obj_phone = phone_numbers.find(phone_type: the_type)
    obj_phone = phone_numbers.find_by(phone_type: the_type)
    if id.nil?
      ret_obj = phone_numbers.build
      ret_obj.phone_type = the_type
    elsif obj_phone.nil?
      ret_obj = PhoneNumber.create(user_id: id, phone_type: the_type)
      phone_numbers.reload # refreshes cache
    else
      ret_obj = obj_phone
    end
    ret_obj
  end
end
