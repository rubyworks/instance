# Instance

First thing we need to do, of course, is load the library.

    require 'instance'

Now we can create an example class with which to work.

    class ::Friend
      attr_accessor :name, :age, :phone

      def initialize(name, age, phone)
        @name, @age, @phone = name, age, phone
      end
    end

And now demonstrate the available API.

## Instance#variables

    f1 = Friend.new("John", 30, "555-1212")
    f1.instance.variables.assert == [:@name, :@age, :@phone]

## Instance#names

    f1 = Friend.new("John", 30, "555-1212")
    f1.instance.names.assert == ["name", "age", "phone"]

## Instance#keys

    f1 = Friend.new("John", 30, "555-1212")
    f1.instance.keys.assert == [:name, :age, :phone]

## Instance#values

    f1 = Friend.new("John", 30, "555-1212")
    f1.instance.values.assert == ["John", 30, "555-1212"]

## Instance#size

The `#size` method reports how many instance variables are defined.

    f = Friend.new("John", 30, "555-1212")
    f.instance.size.assert == 3

This method is primarily of use to the Enumerable mixin.

## Instance#variable_defined?

    f = Friend.new("John", 30, "555-1212")
    f.instance.assert.variable_defined?(:@name)
    f.instance.assert.variable_defined?(:name)

## Instance#update and #assign

    f1 = Friend.new("John", 30, "555-1212")
    f1.name.assert == 'John'

    f1.instance.update(:name=>'Jerry')
    f1.name.assert == 'Jerry'

    f1.instance.assign(:name=>'John')
    f1.name.assert == 'John'

## Instance#to_h

We can convert the object's state, i.e. it's instance variable names and values
into a Hash very easily with the `#to_h` method.

    f1 = Friend.new("John", 30, "555-1212")
    f1.instance.to_h.assert == {:name=>"John", :age=>30, :phone=>"555-1212"}

Notice that the `@` has beenn removed from the instance variable names. If we
want the `@` to stay simply pass `true` to the `#to_h` method.

    f1 = Friend.new("John", 30, "555-1212")
    f1.instance.to_h(true).assert == {:@name=>"John", :@age=>30, :@phone=>"555-1212"}

## Instance#class

    f = Friend.new("John", 30, "555-1212")
    f.instance.class.assert == ::Friend

## Instance#id

    f = Friend.new("John", 30, "555-1212")
    f.instance.id == f.object_id

## Instance#of?

    f = Friend.new("John", 30, "555-1212")
    f.instance.assert.of?(::Friend)

## Instance#get and #set

    f = Friend.new("John", 30, "555-1212")
    f.instance.get(:name).assert == "John"
    f.instance.set(:name, "Bill")
    f.name.assert == "Bill"

## Instance#remove

    f = Friend.new("John", 30, "555-1212")
    f.instance.remove(:name)
    f.instance.refute.variable_defined?(:@name)

## Instance#method

The Instance class provides a `method` method for getting a Method object for
any of the target object's methods by name.

    f1 = Friend.new("John", 30, "555-1212")
    m  = f1.instance.method(:name)
    m.assert.is_a?(::Method)

This can seem a little confusing because Ruby's `instance_method` method actually
returns an `UnboundMethod` object. Unfortunately Ruby's use of the term `instance_method`
is a complete misnomer. It should be something like `method_definition` instead.
The actual *instance method* is the object's method.

## Instance#methods

    f = Friend.new("John", 30, "555-1212")
    f.instance.methods
    f.instance.methods(:private)
    f.instance.methods(:protected)
    f.instance.methods(:public)
    f.instance.methods(:public, :private)

## Instance#eval and #exec

    f = Friend.new("John", 30, "555-1212")
    f.instance.eval("@name").assert == "John"
    f.instance.exec{ @name }.assert == "John"

## Instance#send

Sending a message to an object as if within the object itself and thus by-passing
method visibility is somehting that should only be done as an act of *metaprogramming*.
Hence it makes sense for it to be done via the `instance` interface.

    f = Friend.new("John", 30, "555-1212")
    f.send(:name).assert == "John"

## Instance#delegate

    f = Friend.new("John", 30, "555-1212")
    f.instance.delegate.assert == f

