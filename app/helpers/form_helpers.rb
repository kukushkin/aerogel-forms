module Aerogel::Helpers

  def form( object = nil, options = {}, &block )
    Aerogel::Forms::FormBuilder.new( object, options, &block ).render
  end

  # Renders input hidden tag.
  #
  def input_hidden_tag( name, value )
    tag :input, type: 'hidden', name: name, value: value
  end

end # module Aerogel::Helpers

