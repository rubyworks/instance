# Instance

## What Is It?

Instance is a *convenient* and *safe* API for accessing and manipulating
an object's state.

## How Does It Work

Instance adds a method to all objects called `#instance`. It returns
an `Instance` delegator that provides the full interface to the
object's instance state.

Of course, without implementing this in C, directly in the Ruby source,
we  are left to depend on the current provisions Ruby has for accessing
the state of an object. So there are some limitations here. However,
we implement the Ruby code in such a way as to minimize the downsides
by caching all the method definitions the Instance class will utilize.

## Usage

Let's use a very simple example class with which to demonstrate usage.

```ruby
    class Song
      attr_accessor :title
      attr_accessor :author
      attr_accessor :length

      def initialize(title, author, length)
        @title  = title
        @author = author
        @length = length
      end
    end
```

```ruby
    song = Song.new("Paranoid", "Black Sabbath", 1970)

    song.instance.variables   #=> [:@author, :@title, :@length]

    song.instance.get(:name)  #=> "Black Sabbath"

    song.instance[:name]      #=> "Black Sabbath"
```

For more a more complete set of usage examples see the QED documentation.


## Copyrights

Copyright 2014 Rubyworks

BSD-2-Clause License

See LICENSE.txt file for license details.

