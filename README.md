puppet-kiosk 
===================

 !! Read the help pages on: https://github.com/naturalis/puppet-kiosk/wiki

Puppet module to install a simple kiosk browser.It installs bare Xorg, Openbox window manager and:

* kiosk::java =
Java applet with transparent mouse cursor. There is a zip file with the open code and a protected zip file with Naturalis images.
* kiosk::chrome =
Chrome browser gpu forced with transparent mouse cursor, together with Squid3 local proxy. Made for html5. There is also a possibility to enable apache2.

First we used the Midori browser, but because it doesnt have a good html5 compatibility we moved to google-chrome (since chromium isnt compatible yet with ubuntu 14.04).

Parameters
-------------
All parameters are read from defaults in init.pp and can be overwritten by The foreman.

```
kiosk::java >
$packages                             = ['xorg','openbox','openjdk-7-jre','p7zip-full','build-essential'],
$extractpassword                      = undef,
$applet_name                          = undef,
$applet_images                        = undef,
$platform                             = undef,
$images_path                          = undef,
$interactive_name                     = undef,
$dirs                                 = ['/home/kiosk/','/home/kiosk/.config','/home/kiosk/.config/openbox','/home/kiosk/.icons/','/home/kiosk/.icons/default/','/home/kiosk/.icons/default/cursors'],

kiosk::chrome >
$packages                             = ['xorg','openbox','squid3','build-essential'],
$dirs                                 = ['/home/kiosk/','/home/kiosk/.config','/home/kiosk/.config/google-chrome','/home/kiosk/.config/google-chrome/Default','/home/kiosk/.config/google-chrome/Default/Extensions','/home/kiosk/.config/openbox','/home/kiosk/.icons/','/home/kiosk/.icons/default/','/home/kiosk/.icons/default/cursors'],
$browser_path                         = "google-chrome --disable-translate --load-extension=/home/kiosk/.config/google-chrome/Default/Extensions/ --proxy-server=http://localhost:8080 --no-first-run --kiosk --allow-file-access-from-files http://www.naturalis.nl/nl/het-museum/agenda/",
$homepage                             = "http://www.naturalis.nl/nl/het-museum/agenda/",
$acl_whitelist                        = ['.naturalis.nl/nl/het-museum/agenda/|.naturalis.nl/media|.naturalis.nl/static/*'],
$deny_info                            = "http://www.naturalis.nl/nl/het-museum/agenda/",
$cache_peer                           = ['.naturalis.nl/nl/het-museum/agenda/'],
$http_port                            = "8080",
$cache_mem                            = "128 MB",
$cache_max_object_size                = "1024 MB",
$cache_maximum_object_size_in_memory  = "512 KB",
$enable_apache                        = false,
$webpackages                          = ['apache2','php5','libapache2-mod-php5','p7zip-full'],
$extractpassword                      = undef,
$applet_name                          = undef,
```
Limitations
-------------
This module has been built on and tested against Puppet 3.2.3 and higher.

The module has been tested on
- Ubuntu Server 12.04, 13.10 & 14.04.

Dependencies
-------------
- stdlib

Authors
-------------
<foppe.pieters@naturalis.nl>
