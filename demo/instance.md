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

## Variable Names and Values

    f1 = Friend.new("John", 30, "555-1212")

    f1.instance.variables.assert == [:@name, :@age, :@phone]

    f1.instance.names.assert == ["name", "age", "phone"]

    f1.instance.keys.assert == [:name, :age, :phone]

    f1.instance.values.assert == ["John", 30, "555-1212"]

## Update and Assign

    f1 = Friend.new("John", 30, "555-1212")
    f1.name.assert == 'John'

    f1.instance.update(:name=>'Jerry')
    f1.name.assert == 'Jerry'

    f1.instance.assign(:name=>'John')
    f1.name.assert == 'John'


## Convert State to Hash

    f1.instance.to_h.assert == {:name=>"John", :age=>30, :phone=>"555-1212"}
