require 'aerogel/core'
require "aerogel/forms/version"
require 'aerogel/forms/form_object'
require 'aerogel/forms/form_field'
require 'aerogel/forms/fieldset'
require "aerogel/forms/form_builder"

module Aerogel
  # Finally, register module's root folder
  register_path File.join( File.dirname(__FILE__), '..', '..' )
end

