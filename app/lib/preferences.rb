##
# Implement a preferences mechanism
module Preferences
  def set_childs_selected_fiscal_year(child, fy)
    # puts "child: #{child.inspect} fy: #{fy}"
    # TODO: Fix the following line to be like the one a few below.
    set_child_preference(child, :selected_fiscal_year, fy) if fy
  end

  def childs_selected_fiscal_year(child)
    child.fiscal_year(child_preference(child, :selected_fiscal_year, child.fiscal_years.first))
  end

  def set_childs_panel_state(child, state)
    set_child_preference(child, :panel_state, state).to_sym
  end

  def childs_panel_state(child)
    child_preference(child, :panel_state, :open).to_sym
  end

  private

  def json(s)
    JSON.parse(s || '{}')
  end

  def set_child_preference(child, key, value)
    logger.debug do
      "Set child preference: #{child.my_name} " \
      "{ #{key}: #{value} }"
    end
    self.preferences = json(preferences).merge(child.id.to_s => { key => value }).to_json
    logger.debug { "Set child preferences: #{preferences}" }
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
end
