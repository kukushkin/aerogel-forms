module Aerogel::Render

# Fieldset represents a set of fields for a nested form object.
#
class Fieldset < FormObject

  def wrap( content )
    erb template( :fieldset ), locals: { fieldset: self, content: content }, layout: false
  end

  # Hidden field of a nested object
  #
  def hidden( name, value = nil )
    f = data_field name
    tag :input, type: :hidden, name: f.html_name, value: (value || f.value)
  end

end # class Fieldset

end # module Aerogel::Render