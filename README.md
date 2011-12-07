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

**Video of a complete installation on Ubuntu 11.10**

[http://www.youtube.com/watch?v=GQXyJR6mOk0](http://www.youtube.com/watch?v=GQXyJR6mOk0)

This is a video of a complete start-to-finish installation on a fresh install of Ubuntu 11.10. 

The commands used in the video can be found at [https://gist.github.com/1428474](https://gist.github.com/1428474).

**Set up DNS**

Before you can use SiriProxy, you must set up a DNS server on your network to forward requests for guzzoni.apple.com to the computer running the proxy (make sure that computer is not using your DNS server!). I recommend dnsmasq for this purpose. It's easy to get running and can easily handle this sort of behavior. ([http://www.youtube.com/watch?v=a9gO4L0U59s](http://www.youtube.com/watch?v=a9gO4L0U59s))

**Set up RVM and Ruby 1.9.3**

If you don't already have Ruby 1.9.3 installed through RVM, please do so in order to make sure you can follow the steps later. Experts can ignore this. If you're unsure, follow these directions carefully:

1. Download and install RVM (if you don't have it already):
	* Download/install RVM:  
		`bash < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)`  
	* Activate RVM:  
		`[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"`  
	* (optional, but useful) Add RVM to your .bash_profile:  
		`echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function' >> ~/.bash_profile`   
2. Install Ruby 1.9.3 (if you don't have it already):   
	`rvm install 1.9.3`  
3. Set RVM to use/default to 1.9.3:   
	`rvm use 1.9.3 --default`
	
**Set up SiriProxy**

Clone this repo locally, then navigate into the SiriProxy directory (the root of the repo). Then follow these instructions carefully. Note that nothing needs to be (or should be) done as root until you launch the server:

1. Install Rake and Bundler:  
	`rvmsudo gem install rake bundler`  
2. Install SiriProxy gem (do this from your SiriProxy directory):  
	`rake install`  
3. Make .siriproxy directory:  
	`mkdir ~/.siriproxy`  
4. Move default config file to .siriproxy (if you need to make configuration changes, do that now by editing the config.yml):  
	`cp ./config.example.yml ~/.siriproxy/config.yml`  
5. Generate certificates:  
	`siriproxy gencerts`
6. Install `~/.siriproxy/ca.pem` on your phone. This can easily be done by emailing the file to yourself and clicking on it in the iPhone email app. Follow the prompts.
7. Bundle SiriProxy (this should be done every time you change the config.yml):  
	`siriproxy bundle`
8. Start SiriProxy (must start as root because it uses a port < 1024):  
	`rvmsudo siriproxy server`
9. Test that the server is running by saying "Test Siri Proxy" to your phone.

Note: on some machines, rvmsudo changes "`~`" to "`/root/`". This means that you may need to symlink your "`.siriproxy`" directory to "`/root/`" in order to get the application to work:  

	sudo ln -s ~/.siriproxy /root/.siriproxy

**Updating SiriProxy**

Once you're up and running, if you modify the code, or you want to grab the latest code from GitHub, you can do that easily using the "siriproxy update" command. Here's a couple of examples:

	siriproxy update  
	
Installs the latest code from the [master] branch on GitHub.
	
	siriproxy update /path/to/SiriProxy  

Installs the code from /path/to/SiriProxy
	
	siriproxy update -b gemify 

Installs the latest code from the [gemify] branch on GitHub
	

FAQ
---

**Will this let me run Siri on my iPhone 4, iPod Touch, iPhone 3G, Microwave, etc?**

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

You're probably not using an iPhone 4S. You need to be using an iPhone 4S (or have a UDID you can sub in) in order to make use of SiriProxy. Sorry, this is not designed to be a way around that limitation. (Thanks to [@brownie545](http://www.twitter.com/brownie545) for providing information on what happens when you use a non-iPhone 4S)

**How do I remove the certificate from my iPhone when I'm done?**

Just go into your phone's Settings app, then go to "General->Profiles." Your CA will probably be the only thing listed under "Configuration Profiles." It will be listed as "SiriProxyCA" Just click it and click "Remove" and it will be removed. (Thanks to [@tidegu](http://www.twitter.com/tidegu) for asking!)

**Does this require a jailbreak?**

No. The only action you need to take on the phone is to install the root CA's public key.


Acknowledgements
----------------
I really can't give enough credit to [Applidium](http://applidium.com/en/news/cracking_siri/) and the [tools they created](https://github.com/applidium/Cracking-Siri). While I've been toying with Siri for a while, their proof of concept for intercepting and interpreting the Siri protocol was invaluable. Although all the code included in the project (so far) is my own, much of the base logic behind my code is based on the sample code they provided. They do great work.

I also want to give a shout-out to [Arch Reactor](http://www.archreactor.org) - my local Hackerspace. Hackerspaces are a fantastic place to go learn about stuff like this. I was able to get some help from folks there, and more importantly, I got encouragement to do stuff like this. Check [Hackerspaces.org](http://www.hackerspaces.org) for a hackerspace in your area and make sure to check it out! 

Licensing
---------

Re-use of my code is fine under a Creative Commons 3.0 [Non-commercial, Attribution, Share-Alike](http://creativecommons.org/licenses/by-nc-sa/3.0/) license. In short, this means that you can use my code, modify it, do anything you want. Just don't sell it and make sure to give me a shout-out. Also, you must license your derivatives under a compatible license (sorry, no closed-source derivatives). If you would like to purchase a more permissive license (for a closed-source and/or commercial license), please contact me directly. See the Creative Commons site for more information.


Disclaimer
----------
I'm not affiliated with Apple in any way. They don't endorse this application. They own all the rights to Siri (and all associated trademarks). 

This software is provided as-is with no warranty whatsoever. Apple could do things to block this kind of behavior if they want. Also, if you cause problems (by sending lots of trash to the Guzzoni servers or anything), I fully support Apple's right to ban your UDID (making your phone unable to use Siri). They can, and I wouldn't blame them if they do.

I'm a huge fan of Apple and the work that they do. Siri is a very cool feature and I'm pretty excited to explore it and add functionality. Please refrain from using this software for anything malicious.

Also, this is my first project done in Ruby. Please don't be too critical of my code.
