##
# Implement a preferences mechanism
module Preferences
  ##
  # Return true if the user has once acknowledged the notification
  # that the forms are only for residents of BC.
  def bc_warning_acknowledgement?
    preference(:bc_warning_acknowledgement, false)
  end

  def childs_panel_state(child)
    child_preference(child, :panel_state, :open).to_sym
  end

  def childs_selected_fiscal_year(child)
    child.fiscal_year(child_preference(child, :selected_fiscal_year, child.fiscal_years.first))
  end

  def set_bc_warning_acknowledgement(state)
    set_preference(bc_warning_acknowledgement: state)
  end

  def set_childs_panel_state(child, state)
    set_child_preference(child, :panel_state, state).to_sym
  end

  def set_childs_selected_fiscal_year(child, fy)
    # puts "child: #{child.inspect} fy: #{fy}"
    child.fiscal_year(set_child_preference(child, :selected_fiscal_year, fy)) if fy
  end

  private

  def json(s)
    JSON.parse(s || '{}')
  end

  def set_child_preference(child, key, value)
    set_preference(child.id.to_s => { key => value })
    save
    value
  end

  def child_preference(child, key, default)
    logger.debug { "Child preferences args: #{child.inspect}, #{key}(#{key.class})" }
    logger.debug { "Child preferences: #{preferences}" }
    pref_hash = json(preferences)
    logger.debug { "Child preferences hash: #{pref_hash}" }
    value = (pref_hash && pref_hash[child.id.to_s] && pref_hash[child.id.to_s][key.to_s])
    logger.debug { "Child preferences value before default: #{value}" }
    value ||= default
    logger.debug { "Child preferences value: #{value}" }
    value
  end

  def set_preference(hash)
    logger.debug { "Set preference new hash: #{hash}" }
    self.preferences = json(preferences).merge(hash).to_json
    logger.debug { "Set preference preferences: #{preferences}" }
    save
  end

  def preference(key, default)
    logger.debug { "Preference args: #{key}(#{key.class})" }
    logger.debug { "Preferences: #{preferences}" }
    pref_hash = json(preferences)
    logger.debug { "Preferences hash: #{pref_hash}" }
    value = pref_hash && pref_hash[key.to_s]
    logger.debug { "Preferences value before default: #{value}" }
    value ||= default
    logger.debug { "Preferences value: #{value}" }
    value
  end
end
