# Instance class is a delgator for any object which provides
# an elegant and protected interface to an object's state, i.e.
# its *instance*.
#
# Examples
#
#   class Friend
#     attr_accessor :name, :age, :phone
#     def initialize(name, age, phone)
#       @name, @age, @phone = name, age, phone
#     end
#   end
#
#   f1 = Friend.new("John", 30, "555-1212")
#   f1.instance
#
#   f1.instance.update({:name=>'Jerry'})
#   f1.instance
#
# TODO: Should we add `is_a?` and `kind_of?` too?

class Instance
  include Enumerable

  # Store Object methods so they cannot be overriden by the delegate class.
  METHODS = {}

  def self.freeze_method(name)
    METHODS[name.to_sym] = Object.instance_method(name)
  end

  freeze_method :object_id
  freeze_method :class
  freeze_method :instance_of?
  freeze_method :method
  freeze_method :methods
  freeze_method :public_methods
  freeze_method :protected_methods
  freeze_method :private_methods
  freeze_method :instance_eval
  freeze_method :instance_exec
  freeze_method :instance_variables
  freeze_method :instance_variable_get
  freeze_method :instance_variable_set
  freeze_method :instance_variable_defined?
  freeze_method :remove_instance_variable
  freeze_method :send

  #module Kernel
  #  # Returns an instance of Instance for +self+,
  #  # which allows convenient access to an object's
  #  # internals.
  #  def instance
  #    Instance.instance(self)
  #  end
  #end

  # Instance cache acts as a global cache for instances of Instance.
  @cache = {}

  # Instance is multiton. Use this method instead of #new to get a
  # cached instance.
  def self.instance(delegate)
    @cache[delegate] ||= Instance.new(delegate)
  end

  # Initialize new Instance instance. If the delegate is a type of 
  # Module or Class then the instance will be extended with the
  # {ModuleExtensions} mixin.
  # 
  def initialize(delegate)
    @delegate = delegate
    extend ModuleExtensions if Module === delegate
  end

  # The delegated object.
  def delegate
    @delegate
  end

  # Iterate over instance variables.
  def each
    variables.each do |name|
      yield(name[1..-1].to_sym, get(name))
    end
  end

  # Number of instance variables.
  def size
    variables.size
  end

  # Get instance variables with values as a hash.
  #
  # Examples
  #
  #   class X
  #     def initialize(a,b)
  #       @a, @b = a, b
  #     end
  #   end
  #
  #   x = X.new(1,2)
  #
  #   x.instance.to_h  #=> { :a=>1, :b=>2 }
  #
  # Returns [Hash].
  def to_h(at=false)
    h = {}
    if at
      variables.each do |name|
        h[name] = get(name)
      end
    else
      each do |key, value|
        h[key] = value
      end
    end
    h
  end

  # TODO: Not sure if this should be used.
  alias_method :to_hash, :to_h

  #
  def get(name)
    name = atize(name)
    #@delegate.instance_variable_get(name)
    METHODS[:instance_variable_get].bind(@delegate).call(name)
  end
  alias :[] :get

  #
  def set(name, value)
    name = atize(name)
    #@delegate.instance_variable_set(name,value)
    METHODS[:instance_variable_set].bind(@delegate).call(name,value)
  end
  alias :[]= :set

  #
  def <<(pair)
    name, value = *pair
    name = atize(name)
    set(name, value)
  end

  # Remove instance variable.
  def remove(name)
    name = atize(name)
    METHODS[:remove_instance_variable].bind(@delegate).call(name)
  end

  # Set instance variables given a +hash+.
  #
  #   instance.update('@a'=>1, '@b'=>2)
  #   @a   #=> 1
  #   @b   #=> 2
  #
  # Also, +@+ sign is not neccessary.
  #
  #   instance.update(:a=>1, :b=>2)
  #   @a   #=> 1
  #   @b   #=> 2
  #
  def update(hash)
    hash.each do |pair|
      self << pair
    end
  end

  # A hold-over from the the old #instance_assign method.
  alias_method :assign, :update

  # Same as #instance_variables.
  def variables
    #@delegate.instance_variables
    METHODS[:instance_variables].bind(@delegate).call
  end

  # Instance vairable names as symbols.
  #
  # Returns [Array<Symbols>].
  def keys
    variables.collect do |name|
      name[1..-1].to_sym
    end
  end

  # Instance variable names as strings.
  #
  # Returns [Array<String>].
  def names
    variables.collect do |name|
      name[1..-1]
    end
  end

  # Instance variable values.
  #
  # Returns [Array<Object>].
  def values
    variables.collect do |name|
      get(name)
    end
  end

  # Instance evaluation.
  def eval(*a,&b)
    #@delegate.instance_eval(*a,&b)
    METHODS[:instance_eval].bind(@delegate).call(*a,&b)
  end

  # Instance execution.
  def exec(*a,&b)
    #@delegate.instance_exec(*a,&b)
    METHODS[:instance_exec].bind(@delegate).call(*a,&b)
  end

  # Get method. Usage of this might seem strange because Ruby's own
  # `instance_method` method is a misnomer. It should be something
  # like `definition` or `method_definition`. In Ruby the acutal
  # "instance" method is accessed via the unadorned `method` method.
  #
  # Returns [Method].
  def method(name)
    #@delegate.instance_exec(*a,&b)
    METHODS[:method].bind(@delegate).call(name)
  end

  # Returns list of method names.
  #
  # Returns [Array<Symbol>].
  def methods(*selection)
    list = []

    if selection.empty?
      list.concat METHODS[:methods].bind(@delegate).call
    end

    selection.each do |s|
      case s
      when :public, :all
        list.concat METHODS[:public_methods].bind(@delegate).call
      when :protected, :all
        list.concat METHODS[:protected_methods].bind(@delegate).call
      when :private, :all
        list.concat METHODS[:private_methods].bind(@delegate).call
      end
    end

    return list
  end

  # Is the object an instance of a given class?
  #
  # Returns [Boolean]
  def of?(a_class)
    #@delegate.instance_of?(aclass)
    METHODS[:instance_of?].bind(@delegate).call(a_class)
  end

  #
  def variable_defined?(name)
    name = atize(name)
    #@delegate.variable_defined?(name)
    METHODS[:instance_variable_defined?].bind(@delegate).call(name)
  end

  # Get object's instance id.
  #
  # Returns [Integer]
  def id
    #@delegate.variable_defined?(name)
    METHODS[:object_id].bind(@delegate).call
  end

  # Fallback to get the real class of the Instance delegate itself.
  alias :object_class :class

  # Get object's instance id.
  #
  # Returns [Class]
  def class
    #@delegate.variable_defined?(name)
    METHODS[:class].bind(@delegate).call
  end

  # Send message to instance.
  def send(*a, &b)
    METHODS[:send].bind(@delegate).call(*a, &b)
  end

private

  def atize(name)
    name.to_s !~ /^@/ ? "@#{name}" : name
  end

  ##
  # ModuleExtensions provides some additional methods for Module and Class
  # objects.
  #
  # TODO: Are there any other module/class methods that need to be provided?
  #
  module ModuleExtensions
		# Store Object methods so they cannot be overriden by the delegate class.
		METHODS = {}

		def self.freeze_method(name)
		  METHODS[name.to_sym] = Module.instance_method(name)
		end

		freeze_method :instance_method
		freeze_method :instance_methods
		freeze_method :public_instance_methods
		freeze_method :protected_instance_methods
		freeze_method :private_instance_methods

    # List of method definitions in a module or class.
    #
    # selection - Any of `:public`, `:protected` or `:private` which
    #             is used to select specific subsets of methods.
    #
    # Returns [Array<Symbol>]
    def method_definitions(*selection)
		  list = []

		  if selection.empty?
		    list.concat METHODS[:instance_methods].bind(@delegate).call
		  end

		  selection.each do |s|
		    case s
		    when :public, :all
		      list.concat METHODS[:public_instance_methods].bind(@delegate).call
		    when :protected, :all
		      list.concat METHODS[:protected_instance_methods].bind(@delegate).call
		    when :private, :all
		      list.concat METHODS[:private_instance_methods].bind(@delegate).call
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
		  METHODS[:instance_method].bind(@delegate).call(name)
    end

    alias :definition :method_definition
  end

  #
  #module ClassExtensions
  #
  #end

end


class BasicObject
  # Returns an instance of Instance for `self`, which allows convenient
  # access to an object's internals.
  def instance
    ::Instance.instance(self)
  end
end

