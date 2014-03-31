module Aerogel::Forms

# FormObject represents a model object associated with current form context.
# It provides access to model object fields and helper methods to form proper html.
#
# Example:
#   form for: objectA  <- FormObject
#     nested form for: objectB  <- FormObject
#     list of nested form for collection: objectC1, objectC2..., objecCN
#
class FormObject < Aerogel::Render::BlockHelper

  attr_accessor :object, :parent, :relation, :options

  RESERVED_FIELDS = ['id', '_id']

  def initialize( object, parent = nil, relation = nil, options = {}, &block )
    super( &block )
    self.object = object
    self.parent = parent
    self.relation = relation
    @first_input = nil
    @options = options
  end

  def field( name, options = {} ) # -> Field
    f = data_field name, options
    unless @first_input || options.key?( :readonly )
      @first_input = f
      f.options[:autofocus] = nil
    end
    erb template( :field, f.options ), locals: { field: f, form_builder: self }, layout: false
  end

  # Renders fields listed in the arguments.
  #
  def fields( *args )
    args = object.attribute_names - RESERVED_FIELDS if args.size == 0
    output = ''
    args.each do |f|
      output += field f
    end
    output
  end

  def fieldset( name_or_object, opts = {}, &block )
    # TODO: if name.nil?
    if name_or_object.is_a? Symbol
      name = name_or_object
      if data_field( name ).is_collection?
        i = 0
        object.send( name ).each do |o|
          Fieldset.new( o, self, name, opts.merge( object_index: i ), &block ).render
          i += 1
        end
      else
        Fieldset.new( object.send( name ), self, name, opts, &block ).render
      end
    else
      # create new fieldset for given object with no parent
      Fieldset.new( name_or_object, opts[:parent], opts[:name], opts, &block ).render
    end
  end

  # Returns data object name.
  # If the object name is not explicitly specified, it is inferred from
  # the model name.
  #
  def object_name
    return @object_name if @object_name
    if @options[:object_name]
      @object_name = @options[:object_name]
    elsif object.respond_to? :model_name
      @object_name = object.model_name.singular
    else
      @object_name = nil
    end
    @object_name
  end

  # Returns true if current form object is the root.
  #
  def root_object?
    parent.nil?
  end

  # Returns field prefix for the current form object.
  #
  def field_prefix
    if root_object?
      # root
      object_name
    elsif parent.data_field( relation ).is_collection?
      # 1 - N, accepts nested attributes
      if parent.object.respond_to? :"#{relation}_attributes="
        parent.field_prefix+"[#{relation}_attributes][#{options[:object_index]}]"
      else
        parent.field_prefix+"[#{relation}][#{options[:object_index]}]"
      end
    else
      # 1 - 1
      parent.field_prefix+"[#{relation}][]"
    end
  end

  def data_field( name, options = {} )
    FormField.new self, name, options
  end

  # Returns data object id, degrading to self.object_id
  #
  def id
    object.send(:id) rescue self.object_id
  end

  # Returns true if the object contains no errors.
  #
  def valid?
    # object.send(:valid?) rescue true # if valid? not supported
    !object.respond_to?(:errors) || object.errors.nil? || object.errors.size == 0
  end

  # Returns true if the object is not valid, i.e. contains errors.
  #
  def invalid?
    not valid?
  end

end # class FormObject

end # module Aerogel::Forms