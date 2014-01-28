module Aerogel::Helpers

  def form( object = nil, options = {}, &block )
    Aerogel::Forms::FormBuilder.new( object, options, &block ).render
  end

end # module Aerogel::Helpers

