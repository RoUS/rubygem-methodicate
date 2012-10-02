Chained: Ruby Object Method Wrapper
===================================

Chained allows arbitrary objects to be wrapped such that Enumerable
structures can be referenced as though the indices were methods.

For example, in the simplest case:

    irb> hsh = { :key1 => "Value1", "key2" => :Value2 }
    irb> chsh = Chained.new(hsh)
    
    irb> chsh[:key1]
    => "Value1"
    
    irb> chsh.key1
    => "Value1"
    
    irb> chsh.key2
    => :Value2

The wrapping mechanism is perpetuated, which means that the results of
an access to a chained object will themselves be another chained
object.  This allows the technique to be used all the way down to the
bottom turtle:

    irb> deep = { :d1 => { :d2a => { :d3A => [ "d3Av1", "d3Av2" ] }, "D2b" => 17 },
    irb* "d2" => [ { :d2a => "d2av1", "d2b" => [ "d2bv1", "d2bv2" ] }, 3, 4 ] }
    irb> cdeep = Chained.new(deep)
    
    irb> cdeep.d1
    => { :d2a => { :d3A => [ "d3Av1", "d3Av2" ] }, "D2b" => 17 }
    
    irb> cdeep.d2
    => [ { :d2a => "d2av1", "d2b" => [ "d2bv1", "d2bv2" ] }, 3, 4 ]
    
    irb> cdeep.d1.d2a.d3A
    => [ "d3Av1", "d3Av2" ]
    
    irb> cdeep.d1.d2a.d3A[1]
    => "d3Av2"
    
    irb> cdeep.d2[0].d2b
    => [ "d2bv1", "d2bv2" ]


Installation
------------

    $ sudo gem install chained

Usage
-----

     require('chained')
     
     chained_object = Chained.new(raw_object)


License
-------

The Chained gem is Open Source and distributed under the Apache V2 licence.
Please see the LICENCE file included with this software.
