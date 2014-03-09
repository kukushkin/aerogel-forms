module Aerogel::Forms

# Field represents a field of form object.
#
class FormField

  attr_accessor :form_object, :data_object, :name, :options

  # Known options to a field are processed, the rest (unknown options) goes
  # as html params.
  KNOWN_OPTIONS = [ :as, :label, :value, :default_value, :hint ]

  def initialize( form_object, name, options = {} )
    #unless name.is_a? Symbol
    #  raise ArgumentError.new "Field name should be a Symbol"
    #end
    self.form_object = form_object
    self.data_object = form_object.object
    self.name = name.to_sym
    self.options = options
  end

  # Returns true if the field is actually a collection in parent object.
  #
  def is_collection?
    data_object.send( name ).is_a? Array
  end

  # Returns input field type as a Symbol.
  #
  def type
    return @type if @type
    @type = options[:as]
    if data_object.respond_to? :fields
      @type ||= data_object.fields[name.to_s].type.name.downcase.to_sym rescue nil
    end
    @type ||= :string
    @type
  end

  # Returns input field label.
  #
  def label
    return @label if @label
    @label = options[:label]
    @label ||= data_object.fields[name.to_s].label if data_object.respond_to?( :fields ) && data_object.fields[name.to_s]
    @label ||= data_object.class.human_attribute_name( name.to_s, default: '' ) if data_object.class.respond_to?( :human_attribute_name )
    @label = nil if @label == ''
    @label ||= I18n.t "aerogel.forms.attributes.#{name}", default: name.to_s.humanize
    @label
  end

  # Returns input field hint — a piece of short explanation rendered beside the field.
  #
  def hint
    return @hint if @hint
    @hint = options[:hint]
    @hint = data_object.fields[name.to_s].hint if data_object.respond_to?( :fields ) && data_object.fields[name.to_s].respond_to?( :hint )
    @hint
  end

  # Returns placeholder for the field, defaulting to label.
  #
  def placeholder
    options[:placeholder] || label
  end

  # Returns field value.
  #
  def value
    # return nil unless data_object.respond_to? :fields
    return options[:value] if options[:value]
    data_object.send name rescue default_value
  end

  # Returns field default value.
  #
  def default_value
    return options[:default_value] if options[:default_value]
    case type
    when :checkbox
      1
    else
      nil
    end
  end

  # Returns Rack-parseable form field name.
  #
  def html_name
    prefix = form_object.field_prefix
    prefix.nil? ? name.to_s : "#{prefix}[#{name}]"
  end

  # Returns unique css id for the field.
  #
  def css_id
    html_name.parameterize+"-#{form_object.id}"
  end

  # Returns a string of html params for the <input ...> tag.
  #
  def html_params
    attrs = @options.except *KNOWN_OPTIONS
    attrs.map{|n, v| v.nil? ? "#{n}" : "#{n}=\"#{v}\""}.join(" ")
  end

  # Returns list of error messages for the field.
  #
  def errors
    data_object.errors.get name
  end

  # Returns true if the field is valid.
  #
  def valid?
    form_object.valid? || errors.nil?
  end

  # Returns true if the field is invalid
  #
  def invalid?
    not valid?
  end

  # Returns true if the field is required.
  #
  def required?
    return options[:required] if !options[:required].nil?
    if data_object.class.respond_to? :validators_on
      vv = data_object.class.validators_on( name ).map(&:class)
      vv.include?( Mongoid::Validations::PresenceValidator )
    else
      false
    end
  end

end # class Field

end # module Aerogel::Forms
