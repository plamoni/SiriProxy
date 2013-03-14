Siri Proxy
==========

About
-----
Siri Proxy is a proxy server for Apple's Siri "assistant." The idea is to allow for the creation of custom handlers for different actions. This can allow developers to easily add functionality to Siri. 

The main example I provide is a plugin to control [my thermostat](http://www.radiothermostat.com/latestnews.html#advanced) with Siri. It responds to commands such as, "What's the status of the thermostat?", or "Set the thermostat to 68 degrees", or even "What's the inside temperature?"

Notice About Plugins
--------------------

We recently changed the way plugins work very significantly. That being the case, your old plugins won't work. 

New plugins should be independent Gems. Take a look at the included [example plugin](https://github.com/plamoni/SiriProxy/tree/master/plugins/siriproxy-example) for some inspiration. We will try to keep that file up to date with the latest features. 

The State of This Project
------------------------- 

Please remember that this project is super-pre-alpha right now. If you're not a developer with a good bit of experience with networks, you're probably not even going to get the proxy running. But if you do (we are willing to help to an extent, check the IRC chat and my Twitter feed [@plamoni](http://www.twitter.com/plamoni)), then test out building a plugin. It's very easy to do and takes almost no time at all for most experienced developers. Check the demo videos and other plugins below for inspiration!


Find us on IRC
--------------

We now have an IRC channel. Check out the #SiriProxy channel on irc.freenode.net.

Demo Video
-----------

See the system in action here: [http://www.youtube.com/watch?v=AN6wy0keQqo](http://www.youtube.com/watch?v=AN6wy0keQqo)

More Demo Videos and Other Plugins
----------------------------------

For a list of current plugins and some more demo videos, check the [Plugins page](https://github.com/plamoni/SiriProxy/wiki/Plugins) on the wiki.  

Set-up Instructions
-------------------

**NEW Instructions for 0.5.0**

Note that the installation instructions have changed. It's no longer necessary to install dnsmasq. Also, SiriProxy is available via rubygems for easy installation.

**Set up RVM and Ruby 2.0.0**

If you don't already have Ruby 2.0.0 (or at least 1.9.3) installed through RVM, please do so in order to make sure you can follow the steps later. Experts can ignore this. If you're unsure, follow these directions carefully:

1. Install pre-requisites. Veries by system. For a fresh Ubuntu 12.10 install, these seem to be good:

	`sudo apt-get install libxslt1.1 libxslt-dev xvfb build-essential git-core curl libyaml-dev libssl-dev`

2. Download and install RVM (if you don't have it already):
	* Download/install RVM:  
		`curl -L https://get.rvm.io | bash -s stable --ruby`  
	* Update .bashrc:  
		`echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' >> ~/.bashrc`
		`echo 'export PATH=$HOME/.rvm/bin:$PATH' >> ~/.bashrc`  
	* Activate changes:  
		`. ~/.bashrc`   

3. Install Ruby 2.0.0 (if you don't have it already):   

	`rvm install 2.0.0`  

4. Set RVM to use/default to 2.0.0:   

	`rvm use 2.0.0 --default`
	
**Set up SiriProxy**

1. Install SiriProxy Gem
 
	`gem install siriproxy`

2. Create `~/.siriproxy` directory

	`mkdir ~/.siriproxy`

3. Generate Certificates

	`siriproxy gencerts`

4. Transfer certificate to your phone (it will be located at `~/.siriproxy/ca.pem`, email it to your phone)
5. Start SiriProxy (`XXX.XXX.XXX.XXX` should be replaced with your server's IP address, e.g. `192.168.1.100`), `nobody` can be replaced with any un-privileged user.

	`rvmsudo siriproxy server -d XXX.XXX.XXX.XXX -u nobody`

6. Tell your phone to use your SiriProxy server as its DNS server (under your Wifi settings)
7. Test that the server is running by saying "Test Siri Proxy" to your phone.

FAQ
---

**Will this let me run Siri on my none Siri devices (eg. iPhone 4, iPod Touch, iPhone 3G, Microwave, etc)?**

No. Please stop asking. 

**What is your opinion on h1siri, public SiriProxy servers, and other Siri "ports"?**

Glad you asked! Watch this: [http://youtu.be/Y_Q6PfxBSbA](http://youtu.be/Y_Q6PfxBSbA)

**How do I generate the certificate?**

Certificates can now be easily generated using `siriproxy gencerts` once you install the SiriProxy gem. See the instructions above.

**How do I set up a DNS server to forward Guzzoni.apple.com traffic to my computer?**

Check out my video on this: 

[http://www.youtube.com/watch?v=a9gO4L0U59s](http://www.youtube.com/watch?v=a9gO4L0U59s)

**Will this work outside my home network?**

No, it won't. But, as suggested by STBullard on YouTube, you COULD VPN into your home network from outside your house in order to make this work. That would not require a jailbreak. Of course, it also means ALL your traffic gets funneled through your home network. The nice thing about adding an entry to your /etc/hosts file (on a jailbroken phone) is that it funnels only Siri traffic through your home network, and not all your traffic.

**Can you provide me with an iPhone 4S UDID?**

No. Don't even ask.

**I'm getting a bunch of "[Info - Guzzoni] Object: SessionValidationFailed" messages. What's wrong?!**

You're probably using a device without an official Siri. You need to be using an official Siri device (or have a UDID you can sub in) in order to make use of SiriProxy. Sorry, this is not designed to be a way around that limitation. (Thanks to [@brownie545](http://www.twitter.com/brownie545) for providing information on what happens when you use a unofficial Siri-devices)

**How do I remove the certificate from my iPhone when I'm done?**

Just go into your phone's Settings app, then go to "General->Profiles." Your CA will probably be the only thing listed under "Configuration Profiles." It will be listed as "SiriProxyCA" Just click it and click "Remove" and it will be removed. (Thanks to [@tidegu](http://www.twitter.com/tidegu) for asking!)

**Does this require a jailbreak?**

No. The only action you need to take on the phone is to install the root CA's public key.

**Using Siri causes a whole bunch of the following messages, followed by SiriProxy crashing!**

	Create server for iPhone connection
	start conn #<SiriProxy::Connection::Iphone:0x966a400 @signature=880, @processed_headers=false, @output_buffer="", @input_buffer="", @unzipped_input="", @unzipped_output="", @unzip_stream=#<Zlib::Inflate:0x9669640>, @zip_stream=#<Zlib::Deflate:0x96695dc>, @consumed_ace=false, @name="iPhone", @ssled=false>
	[Info - Plugin Manager] Plugins loaded: [#<SiriProxy::Plugin::Example:0x968a818 @manager=#<SiriProxy::PluginManager:0x9685750 @plugins=[...]>>]
	
This is actually really common (but can be tricky to fix). The problem is that your SiriProxy server is using your tainted DNS server. So what happens is this:

1. Your iPhone connects to your server, thinking it's `guzzoni.apple.com`
2. Your server connects to *itself*, thinking that *it's* `guzzoni.apple.com`
3. Your server thinks another iPhone has connected, and repeats step 2.

This goes on forever, or at least a second or two before the server up and dies. The trick is that you need to make sure your server isn't connecting to itself when it requests a connection to `guzzoni.apple.com`. This is actually the default behavior, but many people accidentally mess things up by either (1) setting up their server to use itself as a DNS server (while using dnsmasq to taint the entry for `guzzoni.apple.com`), or (2) putting their server on a network where the DNS server issued by DHCP is tainted to point to the wrong `guzzoni.apple.com`.

So the fix for this varies based on your setup, but one possible fix for scenario 1 (above) on many *NIX machines is to edit `/etc/resolve.conf` and change the `nameserver` entry to `8.8.8.8` (one of Google's public DNS servers). Do this and then restart networking (or just restart the computer) and things should start working.

Your network setup may be different. This is THE most complex part of setting up SiriProxy (getting DNS set up correctly). So once you have this working, you are probably home free. Keep with it, good luck, and have fun!


Running SiriProxy as an unprivileged user
-----------------------------------------

This used to be really hard. Now it's very easy. Just run `rvmsudo siriproxy server -u USER` and SiriProxy will set it's userid to `USER`'s userid.

Running SiriProxy via Upstart
-----------------------------

**NOTE: This section needs to be updated.** It was written before some of the newer features for SiriProxy. It should be much simpler now.

Here's the upstart script I created for my home SiriProxy server. It respawns on a crash because SiriProxy is delicate and likes to crash. My server is running BackTrack 5 (a derivative of Ubuntu 10.04, I believe) and I use it as my wireless access point, making it an obvious location for SiriProxy:

	description	"SiriProxy server"
	
	#Not sure if this is right, but it seems to work.
	start on (started networking
			  and filesystem)
	
	stop on runlevel [!023456]
	
	respawn
	
	exec start-stop-daemon --start --exec /home/siriproxy/src/SiriProxy/siriproxy2000.sh

Here are the contents of `siriproxy2000.sh` (as referenced above):

	#!/bin/bash
	
	#make sure that rvm is set up
	[[ -s "/home/siriproxy/.rvm/scripts/rvm" ]] && . "/home/siriproxy/.rvm/scripts/rvm"
	
	#feel free to insert logging if needed.
	siriproxy server --port 2000 > /dev/null 2>&1 
	
Note that I run my server on port 2000 as the siriproxy user. See the comments above about running as an unprivileged user.


Acknowledgements
----------------
I really can't give enough credit to [Applidium](http://applidium.com/en/news/cracking_siri/) and the [tools they created](https://github.com/applidium/Cracking-Siri). While I've been toying with Siri for a while, their proof of concept for intercepting and interpreting the Siri protocol was invaluable. Although all the code included in the project (so far) is my own, much of the base logic behind my code is based on the sample code they provided. They do great work.

I also want to give a shout-out to [Arch Reactor](http://www.archreactor.org) - my local Hackerspace. Hackerspaces are a fantastic place to go learn about stuff like this. I was able to get some help from folks there, and more importantly, I got encouragement to do stuff like this. Check [Hackerspaces.org](http://www.hackerspaces.org) for a hackerspace in your area and make sure to check it out! 

Regarding Licensing
-------------------

It's a pain. MIT seems nice. Go hunt through the commit history if you're interested in knowing about SiriProxy's long and frustrating licensing history.

License (MIT)
-------------

SiriProxy - A tampering proxy server for the Siri (Ace) Protocol.
Copyright (c) 2013 Pete Lamonica

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Disclaimer
----------
I'm not affiliated with Apple in any way. They don't endorse this application. They own all the rights to Siri (and all associated trademarks). 

This software is provided as-is with no warranty whatsoever. Apple could do things to block this kind of behavior if they want. Also, if you cause problems (by sending lots of trash to the Guzzoni servers or anything), I fully support Apple's right to ban your UDID (making your phone unable to use Siri). They can, and I wouldn't blame them if they do.

I'm a huge fan of Apple and the work that they do. Siri is a very cool feature and I'm pretty excited to explore it and add functionality. Please refrain from using this software for anything malicious.

Also, this is my first project done in Ruby. Please don't be too critical of my code.
