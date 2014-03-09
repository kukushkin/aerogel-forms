module Aerogel::Forms

class FormBuilder < FormObject

  attr_accessor :options, :content, :style

  DEFAULT_OPTIONS = {
    :style => :standard,
    :method => :post,
#    :action => :default_action,
    :html_params => {'accept-charset' => 'UTF-8'}
  }


  def initialize( object, options, &block )
    super( object, nil, nil, options, &block )
    @options = DEFAULT_OPTIONS.dup.merge( options )
    @style = @options[:style].to_sym
    @hiddens = []
    # hidden :object, object
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
    default_opts = {}
    default_opts[:label] = I18n.t "aerogel.forms.buttons.#{type}", default: type.to_s.humanize
    if String === type || type == :save || type == :create
      type = :submit
    elsif type == :cancel
      default_opts[:url] = back
    end
    options = default_opts.deep_merge options
#    if type == :submit
#      tag :input, { type: :submit, value: :submit }.merge(options)
#    else
#      tag :button, type.to_s.humanize, options
#    end
    erb template( :button ), locals: { type: type, options: options, form_builder: self }, layout: false
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

  def template( name )
    "form_builder/#{@style}/#{name}".to_sym
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
    attrs.map{|n, v| v.nil? ? "#{n}" : "#{n}=\"#{v}\""}.join(" ")
  end

  def render_hiddens
    @hiddens.map{|hidden| (input_hidden_tag hidden[:name], hidden[:value])+"\n" }.join()
  end

end # class FormBuilder

end # module Aerogel::Forms
