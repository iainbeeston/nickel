0.1.5
-----
* Better bugfix for queries containing "anytime"

0.1.4
-----
* Bugfix for queries containing "anytime"

0.1.3
-----
* Bugfix for "cannot load such file -- nickel/version"

0.1.2
-----
* Deprecated ZDate#is_today?, ZTime#is_am? and RecurrenceConstruct#get_interval

0.1.1
-----
* Made ZDate#before?, ZDate#after?, ZTime#before? and ZTime#after? private methods

0.1.0
-----

* Deprecated ZTime#minute and ZTime#second in favor of ZDate#min and ZTime#sec
* Added ZDate#to_date and ZTime#to_time (modsognir)
* Now works on rubinius
* Lots of refactoring and removal of legacy features
