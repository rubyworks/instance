# Instance

## What Is It?



## How Does It Work

Instance adds a method to all objects called `#instance`. It returns
an `Instance` delegator that provides an elegant interface to the
object's instance state.

Of course, without implementing this in C in Ruby source code, we 
are left to depend on the current provisions Ruby has for accessing
the state of an object. So there are some limitations here. However,
we implement the Ruby code in such a way as to minimize the downsides
of being implemented in pure Ruby.


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

    song.instance.variables  #=> [:title, :length, :author]

```



