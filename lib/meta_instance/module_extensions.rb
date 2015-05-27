require_relative "freeze_method"

##
# ModuleExtensions provides some additional methods for Module and Class
# objects.
#
# TODO: Are there any other module/class methods that need to be provided?
#
module MetaInstance::ModuleExtensions
  extend ActiveSupport::Concern

  include MetaInstance::FreezeMethod
  # Store Object methods so they cannot be overriden by the delegate class.

  included do
    freeze_method :instance_method
    freeze_method :instance_methods
    freeze_method :public_instance_methods
    freeze_method :protected_instance_methods
    freeze_method :private_instance_methods
  end

  # List of method definitions in a module or class.
  #
  # selection - Any of `:public`, `:protected` or `:private` which
  #             is used to select specific subsets of methods.
  #
  # Returns [Array<Symbol>]
  def method_definitions(*selection)
    list = []

    if selection.empty?
      list.concat bind_call(:instance_methods)
    end

    selection.each do |s|
      case s
      when :public, :all
        list.concat bind_call(:public_instance_methods)
      when :protected, :all
        list.concat bind_call(:protected_instance_methods)
      when :private, :all
        list.concat bind_call(:private_instance_methods)
      end
    end

    return list
  end

  # Shorter alias for #method_definitions.
  alias :definitions :method_definitions

  # Get a first-class method definition object.
  #
  # Returns an unbound method object. [UnboundMethod]
  def method_definition(name)
    bind_call(:instance_method, name)
  end

  alias :definition :method_definition
end
