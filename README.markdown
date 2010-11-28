crm_di_core
===========

Overview
--------

Experimental plugin module for [Fat Free CRM][2], with the initial target of:

* Exploring a range of integration points for plugin functionality to [Fat Free CRM][2]
* As an example, providing end user (administrator) functionality to manage drop down list values that can then be used in extensions to Fat Free CRM entities as well as a wholey new models that can be integrated with the core product.
* Erm...working out how all this rails stuff hangs together anyway.


Installation
------------

From the root of your Fat Free CRM installation run:

> `./script/plugin install [source]`

Where [source] can be, according to your needs, one of:

> SSH:
>    `git@github.com:jdowson/crm_di_core.git`
>
> Git: 
>    `git://github.com/jdowson/crm_di_core.git`
>
> HTTP:
>    `https://jdowson@github.com/jdowson/crm_di_core.git`



The database migrations required for the plug can be installed with the following command:

> `rake db:migrate:plugin NAME=crm_di_core`

...that can be run from the Fat Free CRM installation root.



Tests
-----

An example of the use of the *lookup* module can be found by installing the [crm_di_contacts][4] plugin, including its demonstration data, which uses the *lookups* module to add custom fields to the *contact* model and UI in Fat Free.

*rspec* tests in the `spec` directory are not currently pushed to [github][3] as, for the time being they are **much** more buggy than the code they are intended to test, so the *develop_test_scripts* branch is staying local for now!


Copyright (c) 2010 [Delta Indigo Ltd.][1], released under the MIT license

[1]: http://www.deltindigo.com/                 "Delta Indigo"
[2]: http://www.fatfreecrm.com/                 "Fat Free CRM"
[3]: http://www.github.com/                     "github"
[4]: https://github.com/jdowson/crm_di_contacts "crm_di_contacts"
