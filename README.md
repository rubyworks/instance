MetaInstance
========
[![Gem Version](http://img.shields.io/gem/v/meta_instance.svg?style=flat-square)](http://badge.fury.io/rb/meta_instance)
[![Build Status](http://img.shields.io/travis/NullVoxPopuli/meta-instance.svg?style=flat-square)](https://travis-ci.org/NullVoxPopuli/meta-instance)
[![Code Climate](http://img.shields.io/codeclimate/github/NullVoxPopuli/meta-instance.svg?style=flat-square)](https://codeclimate.com/github/NullVoxPopuli/meta-instance)
[![Test Coverage](http://img.shields.io/codeclimate/coverage/github/NullVoxPopuli/meta-instance.svg?style=flat-square)](https://codeclimate.com/github/NullVoxPopuli/meta-instance)
[![Dependency Status](http://img.shields.io/gemnasium/NullVoxPopuli/MetaInstance.svg?style=flat-square)](https://gemnasium.com/NullVoxPopuli/MetaInstance)



## What Is It?

MetaInstance is a *convenient* and *safe* API for accessing and manipulating
an object's state.

## How Does It Work

MetaInstance adds a method to all objects called `#instance`. It returns
an `Instance` delegator that provides the full interface to the
object's state.

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
      attr_accessor :artist
      attr_accessor :year

      def initialize(title, artist, year)
        @title  = title
        @artist = artist
        @year   = year
      end
    end
```

Now we can create an instance of Song and work with it's state.

```ruby
    song = Song.new("Paranoid", "Black Sabbath", 1970)

    song.instance.variables
    # => [:@title, :@artist, :@year]

    song.instance.get(:title)
    # => "Paranoid"

    song.instance[:artist]
    # => "Black Sabbath"

    song.instance.to_h
    # => {:title => "Paranoid", :artist => "Black Sabbath", :year => 1970}
```

For a more complete set of usage examples see the [QED](http://rubyworks.github.com/instance/qed.html) documentation.


## Copyrights

Copyright &copy; 2014 [Rubyworks](http://rubyworks.github.io)

BSD-2-Clause License

See [LICENSE.txt](LICENSE.txt) file for license details.
