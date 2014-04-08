module Aerogel::Forms

class FormBuilder < FormObject

  attr_accessor :options, :content

  DEFAULT_OPTIONS = {
    :style => :standard,
    :method => :post,
    :multipart => false,
#    :action => :default_action,
    :html_params => {'accept-charset' => 'UTF-8'}
  }


  def initialize( object, options, &block )
    super( object, nil, nil, options, &block )
    @hiddens = []
    @options = DEFAULT_OPTIONS.dup.deep_merge( options )
    @options[:cancel_url] ||= back
    hidden csrf_field_name, csrf_token if csrf_protected?
    hidden :id, object.id if object.respond_to? :id
  end

  def hidden( name, value )
    @hiddens << { name: name, value: value }
    nil
  end

  # Renders button
  #
  def button( type = :submit, options = {} )
    b = FormButton.new self, type, options
    erb template( :button ), locals: { button: b, type: b.type, options: b.options, form_builder: self }, layout: false
  end

  # Renders a list of buttons
  #
  def buttons( *args )
    args = [:cancel, :submit] if args.size == 0
    output = ''
    args.each do |b|
      output += button b
    end
    output
  end

  def wrap( content )
    erb :"form_builder/#{@style}/form", locals: { form: self, content: content }, layout: false
    # self.instance_exec( self, &STYLES[@style][:form_decorator] )
  end

# private

  # Returns a Hash with <form ..> tag attributes.
  #
  def html_params
    attrs = @options[:html_params].dup
    attrs.merge!({
      :method => @options[:method],
      # :action => @options[:action]
    })
    attrs[:action] = @options[:action] if @options[:action]
    attrs[:enctype] = 'multipart/form-data' if @options[:multipart]
    attrs.map{|n, v| v.nil? ? "#{n}" : "#{n}=\"#{v}\""}.join(" ")
  end

  def render_hiddens
    @hiddens.map{|hidden| (input_hidden_tag hidden[:name], hidden[:value])+"\n" }.join()
  end

end # class FormBuilder

end # module Aerogel::Forms
