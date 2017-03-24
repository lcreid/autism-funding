##
# Helpers for views for children.
module FundedPeopleHelper
  ##
  # Handle collapsible panels with remembered state for open or closed.
  def collapsible_panel(funded_person)
    classes = 'panel-collapse collapse accordion-body'
    logger.debug do
      "Child: #{funded_person.my_name}: " \
      "panel state: #{panel_state(funded_person)}"
    end
    classes += ' in' if panel_state(funded_person) == :open
    content_tag :div,
                id: "collapse-#{funded_person.id}",
                class: classes,
                'aria-labelledby' => "heading-#{funded_person.id}",
                'data-funded-person-id' => funded_person.id.to_s do
                  content_tag :div, class: 'panel-body' do
                    render partial: 'funded_people/show_body',
                           locals: { funded_person: funded_person }
                  end
                end
  end

  def glyphicon_for_panel(funded_person)
    classes = 'glyphicon '
    classes += panel_icon(funded_person)
    content_tag :span, '', class: classes
  end

  private

  def panel_icon(funded_person)
    panel_state(funded_person) == :open ? 'glyphicon-minus' : 'glyphicon-plus'
  end

  def panel_state(funded_person)
    # puts "funded_person.childs_panel_state: #{funded_person.childs_panel_state}"
    funded_person.childs_panel_state
  end
end
