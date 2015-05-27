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

require 'active_support'

require 'meta_instance/version'
require 'meta_instance/freeze_method'
require 'meta_instance/module_extensions'
require 'meta_instance/instance_method_define'
require 'meta_instance/proxy'


class BasicObject
  # Returns an instance of Instance for `self`, which allows convenient
  # access to an object's internals.
  def instance
    ::MetaInstance::Proxy.instance(self)
  end
end
