Nickel
======

[![Gem Version](http://img.shields.io/gem/v/nickel.svg)](http://rubygems.org/gems/nickel)
[![Build Status](http://img.shields.io/travis/iainbeeston/nickel/master.svg)](https://travis-ci.org/iainbeeston/nickel)
[![Coverage Status](http://img.shields.io/coveralls/iainbeeston/nickel/master.svg)](https://coveralls.io/r/iainbeeston/nickel)
[![Code Climate](http://img.shields.io/codeclimate/github/iainbeeston/nickel.svg)](https://codeclimate.com/github/iainbeeston/nickel)
[![Coverage Status](http://img.shields.io/codeclimate/coverage/github/iainbeeston/nickel.svg)](https://codeclimate.com/github/iainbeeston/nickel)

Nickel extracts date, time, and message information from naturally worded text.

Install
-------

If you use bundler add `gem "nickel"` to your gemfile, or if not run `gem install nickel` from the command line.

Usage
-----

A single occurrence

~~~ ruby
n = Nickel.parse "use the force on july 1st at 9am"
n.message                       #=> "use the force"
n.occurrences.first.start_date  #=> "20110701"
~~~

A daily occurrence

~~~ ruby
n = Nickel.parse "wake up everyday at 11am"
n.message                       # => wake up
n.occurrences[0].type           # => daily
n.occurrences[0].start_time     # => 11:00:00
~~~

A weekly occurrence

~~~ ruby
n = Nickel.parse "guitar lessons every tuesday at 5pm"
n.message                       # => guitar lessons
n.occurrences[0].type           # => weekly
n.occurrences[0].day_of_week    # => 1
n.occurrences[0].interval       # => 1
n.occurrences[0].start_time     # => 17:00:00
~~~

A day monthly occurrence

~~~ ruby
n = Nickel.parse "drink specials on the second thursday of every month"
n.message                       # => drink specials
n.occurrences[0].type           # => daymonthly
n.occurrences[0].day_of_week    # => 4
n.occurrences[0].week_of_month  # => 2
n.occurrences[0].interval       # => 1
~~~

A date monthly occurrence

~~~ ruby
n = Nickel.parse "pay credit card every month on the 22nd"
n.message                       # => pay credit card
n.occurrences[0].type           # => datemonthly
n.occurrences[0].date_of_month  # => 22
n.occurrences[0].interval       # => 1
~~~

Multiple occurrences

~~~ ruby
n = Nickel.parse "band meeting every monday and wednesday at 2pm"
n.message                       # => band meeting
n.occurrences[0].type           # => weekly
n.occurrences[0].day_of_week    # => 0
n.occurrences[0].start_time     # => 14:00:00
n.occurrences[1].type           # => weekly
n.occurrences[1].day_of_week    # => 2
n.occurrences[1].start_time     # => 14:00:00
~~~

Occurrences without any message

~~~ ruby
n = Nickel.parse "a week from tomorrow"
n.occurrences[0].start_date     # => 20140320
~~~

Setting current time

~~~ ruby
n = Nickel.parse "lunch 3 days from now", DateTime.new(2010,3,31)
n.message                       # => lunch
n.occurrences[0].start_date     # => 20100403
~~~

Extracting ruby date and time objects

~~~ ruby
n = Nickel.parse "dinner with friends at 8:00pm tonight"
n.message                               # => dinner with friends
n.occurrences[0].start_date.to_date     # => 2014-02-23
n.occurrences[0].start_time.to_time     # => 2014-02-23 20:00:00 +0000
~~~

Credits
-------

Nickel was originally developed by [Lou Zell](https://github.com/lzell/nickel), but is now maintained by [Iain Beeston](https://github.com/iainbeeston/nickel).

Copyright (c) 2008-2013 Lou Zell, lzell11@gmail.com, http://hazelmade.com
