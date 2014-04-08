module Aerogel::Forms

# Button represents a button in a form object.
#
class FormButton

  attr_accessor :form_object, :type, :label, :options

  # Known options to a field are processed, the rest (unknown options) goes
  # as html params.
  KNOWN_OPTIONS = [ :type, :label, :html_params ]

  def initialize( form_object, type, options = {} )
    default_opts = {}
    default_opts[:label] = I18n.t "aerogel.forms.buttons.#{type}", default: type.to_s.humanize
    if String === type || type == :save || type == :create
      type = :submit
    elsif type == :cancel
      default_opts[:url] = form_object.options[:cancel_url]
    end
    options = default_opts.deep_merge options

    self.form_object = form_object
    self.type = type
    self.options = options
  end

  def label
    options[:label]
  end

  # Returns a string of html params for the <button ...> tag.
  #
  def html_params
    attrs = @options.except( *KNOWN_OPTIONS )
    attrs = attrs.deep_merge( @options[:html_params] ) if @options.key? :html_params
    attrs.to_html_params
  end

end # class FormButton

end # module Aeroge::Forms
