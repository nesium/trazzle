CocoaCryptoHashing
==================

About
-----

CocoaCryptoHashing is a very simple and lightweight collection of MD5/SHA1
functions for Cocoa (which sadly does not contain any of these by default). It
provides two categories on both `NSString` and `NSData`. The header file is
pretty well documented, so getting started should not be a problem.

Requirements
------------

You will need Cocoa (and more specifically, Foundation), in order to use
this. OpenSSL is required as well, but since Mac OS X comes with it by
default, this should not be a problem.

License
-------

CocoaCryptoHashing is licensed under the modified BSD license. This license is
included in every file, and is included explicitly in COPYING.

Contact
-------

Any comments, questions, remarks, ... should be sent to
<denis.defreyne@stoneship.org>.

Version History
---------------

*	1.2 [2008-06-09]
	- the libSystem Common Crypto library is now used instead of OpenSSL on
	  Mac OS X and the iPhone (thanks to Chris Verwymeren)
*	1.1 [2005-05-13]
	- fixed lots of incredibly stupid bugs (thanks to D. Brown)
	- added a couple of MD5 and SHA1 test cases
*	1.0 [2005-01-27]
	- initial release
