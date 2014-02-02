# Instance class is a delgator for any object which provides an elegant
# and protected interface to an object's state, i.e. its *instance*.
# Elgence is achieved by providing a single interface, the `instance`
# method. Protection is made possible by caching all the built-in
# Ruby methods used to interface with an object's internal state.
# This way they can not be overriden by some errant code or third
# party library.
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
#   f1.instance.get(:name)  #=> "John"
#   f1.instance.update(:name=>'Jerry')
#   f1.instance.get(:name)  #=> "Jerry"
#
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
  freeze_method :is_a?
  freeze_method :kind_of?

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

  # Get instance variable's value. Will return `nil` if the
  # variable does not exist.
  #
  # Returns the value of the instance variable.
  def get(name)
    name = atize(name)
    bind_call(:instance_variable_get, name)
  end
  alias :[] :get

  # Set instance variable.
  #
  # Returns the set value.
  def set(name, value)
    name = atize(name)
    bind_call(:instance_variable_set, name, value)
  end
  alias :[]= :set

  # Set an instance variable given a name and a value in an array pair.
  #
  # Example
  #
  #   f = Friend.new
  #   f.instance << [:name, "John"]
  #   f.name #=> "John"
  #
  # Returns the set value.
  def <<(pair)
    name, value = *pair
    name = atize(name)
    set(name, value)
  end

  # Remove instance variable.
  def remove(name)
    name = atize(name)
    bind_call(:remove_instance_variable, name)
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
  # Returns nothing.
  def update(hash)
    hash.each do |pair|
      self << pair
    end
  end

  # A hold-over from the the old #instance_assign method.
  alias_method :assign, :update

  # Same as #instance_variables.
  def variables
    bind_call(:instance_variables)
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
    bind_call(:instance_eval, *a, &b)
  end

  # Instance execution.
  def exec(*a,&b)
    bind_call(:instance_exec, *a, &b)
  end

  # Get method. Usage of this might seem strange because Ruby's own
  # `instance_method` method is a misnomer. It should be something
  # like `definition` or `method_definition`. In Ruby the acutal
  # "instance" method is accessed via the unadorned `method` method.
  #
  # Returns [Method].
  def method(name)
    bind_call(:method, name)
  end

  # Returns list of method names.
  #
  # Returns [Array<Symbol>].
  def methods(*selection)
    list = []

    if selection.empty?
      list.concat bind_call(:methods)
    end

    selection.each do |s|
      case s
      when :public, :all
        list.concat bind_call(:public_methods)
      when :protected, :all
        list.concat bind_call(:protected_methods)
      when :private, :all
        list.concat bind_call(:private_methods)
      end
    end

    return list
  end

  # Is the object an instance of a given class?
  #
  # Returns [Boolean]
  def of?(a_class)
    bind_call(:instance_of?, a_class)
  end

  # Is the object an instance of a given class or subclass?
  #
  # Returns [Boolean]
  def is_a?(a_class)
    bind_call(:is_a?, a_class)
  end

  # Is the object an instance of a given class or subclass?
  #
  # Returns [Boolean]
  def kind_of?(a_class)
    bind_call(:kind_of?, a_class)
  end

  # Is an instaance variable defined?
  #
  # Returns [Boolean]
  def variable_defined?(name)
    name = atize(name)
    bind_call(:instance_variable_defined?, name)
  end

  # Get object's instance id.
  #
  # Returns [Integer]
  def id
    bind_call(:object_id)
  end

  # Fallback to get the real class of the Instance delegate itself.
  alias :object_class :class

  # Get object's instance id.
  #
  # Returns [Class]
  def class
    bind_call(:class)
  end

  # Send message to instance.
  def send(*a, &b)
    bind_call(:send, *a, &b)
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

  # TODO: Are there any method we need specific to a Class vs a Module?
  #module ClassExtensions
  #
  #end

  private

  # Helper method for binding the method to the delegate object and calling it.
  def bind_call(method_name, *args, &block) 
    METHODS[mathod_name].bind(@delegate).call(&args, &block)
  end
end


class BasicObject
  # Returns an instance of Instance for `self`, which allows convenient
  # access to an object's internals.
  def instance
    ::Instance.instance(self)
  end
end

