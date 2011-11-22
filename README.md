Siri Proxy
==========

About
-----
Siri Proxy is a proxy server for Apple's Siri "assistant." The idea is to allow for the creation of custom handlers for different actions. This can allow developers to easily add functionality to Siri. 

The main example I provide is a plugin to control [my thermostat](http://www.radiothermostat.com/latestnews.html#advanced) with Siri. It responds to commands such as, "What's the status of the thermostat?", or "Set the thermostat to 68 degrees", or even "What's the inside temperature?"

Find us on IRC
--------------

We now have an IRC channel. Check out the #SiriProxy channel on irc.freenode.net.

Demo Videos
-----------

See the system in action here: [http://www.youtube.com/watch?v=AN6wy0keQqo](http://www.youtube.com/watch?v=AN6wy0keQqo)

See it running with the ELIZA plugin here: [http://www.youtube.com/watch?v=uTiLverShyc](http://www.youtube.com/watch?v=uTiLverShyc)

Other Plugins
-------------

While we encourage people to create SiriProxy plguins, please note that the project is still in very early stages and the **plugin API is still in flux** and may undergo radical changes.

**Sam Lu's Hockey Scores plugin**  
Source: [https://github.com/senmu/SiriProxy/tree/hockeyscores](https://github.com/senmu/SiriProxy/tree/hockeyscores)  
Video: [http://vimeo.com/32431965](http://vimeo.com/32431965)

**Dominick D'Aniello's Twitter plugin (now integrated into main trunk)**  
Source: [https://github.com/plamoni/SiriProxy/blob/master/plugins/twitter/siriTweet.rb](https://github.com/plamoni/SiriProxy/blob/master/plugins/twitter/siriTweet.rb)   
Video: [http://www.youtube.com/watch?v=kM7Th-zcCSc](http://www.youtube.com/watch?v=kM7Th-zcCSc)

**Ninja0091's Dreambox plugin**   
Source: (don't have it yet)  
Video: [http://www.youtube.com/watch?v=jke2bl7Vkbo](http://www.youtube.com/watch?v=jke2bl7Vkbo)   

**Hjaltij's Plex plugin**   
Source: [https://github.com/hjaltij/SiriProxy/](https://github.com/hjaltij/SiriProxy/)   
Video: [http://www.youtube.com/watch?v=jke2bl7Vkbo](http://www.youtube.com/watch?v=jke2bl7Vkbo)   

Set-up Instructions
-------------------

Currently, setup requires a pretty solid knowledge of certificates and openssl (or some good skills with Google). I'll see about providing automated scripts for generating the CA and relavent cert soon.

1. Create a root CA using open SSL and have it issue a signed certificate for guzzoni.apple.com. Save the guzzoni private key (no passphrase) and certificate as "server.passless.key" and "server.passless.crt" in the SiriProxy directory. ([http://www.youtube.com/watch?v=_oaNbPOUCaE](http://www.youtube.com/watch?v=_oaNbPOUCaE)
)
2. Load the root CA's public certificate on your phone (you can just email it to yourself and click it to do that).
3. Set up a DNS server on your network to forward requests for guzzoni.apple.com to the computer running the proxy (make sure that computer is not using your DNS server!). I recommend dnsmasq for this purpose. It's easy to get running and can easily handle this sort of behavior. ([http://www.youtube.com/watch?v=a9gO4L0U59s](http://www.youtube.com/watch?v=a9gO4L0U59s)
)
4. Install the requisite Ruby gems:
	* httparty
	* open-uri (you may not need this on newer versions of Ruby)
	* json
	* CFPropertyList
	* uuidtools
	* eventmachine
	* twitter (you can remove the require for the twitter plugin in start.rb if you don't want/have this gem)
5. Execute start.rb (as root -- since it must listen on TCP/443)
6. Activate Siri on your phone (connected to the network and using the DNS server with the fake entry), and say, "Test Siri proxy." It should respond, "Siri Proxy is up and running!"

FAQ
---

**Will this let me run Siri on my iPhone 4, iPod Touch, iPhone 3G, Microwave, etc?**

No. Please stop asking. 

**How do I generate the certificate?**

Here's some quick(-ish) steps on generating the fake CA and Guzzoni cert (on a Mac):

1. Open a terminal (go to spotlight, type "terminal")
2. Type:

	/System/Library/OpenSSL/misc/CA.pl -newca
3. Enter the following information:
	
	* CA certificate filename: hit enter, it will create a "demoCA" folder
	* Enter PEM pass phrase: give it something 4+ characters that you'll remember. Doesn't need to be complicated
	* Information (Country Name, State Name, etc): Just enter whatever. It's not important
	* Common Name: For the CA, this can be whatever. For the guzzoni certificate, it MUST be: "guzzoni.apple.com"

4. Type:

	/System/Library/OpenSSL/misc/CA.pl -newreq

5. Repeat step 3. Make sure you enter "guzzoni.apple.com" as your Common Name.
6. Type:

	/System/Library/OpenSSL/misc/CA.pl -sign

7. Enter the passphrase from the first time you did step 3.
8. Type "y" in response to each prompt.
9. Type:

	openssl rsa -in newkey.pem -out server.passless.key

10. Enter your passphrase from the second time you did step 3.
11. Type:

	mv newcert.pem server.passless.crt

12. Move server.passless.crt and server.passless.key to your Siri Proxy server.
13. Email cacert.pem from your demoCA folder (created in step 2) to your iPhone. Once it's there, click it and accept it (it will give you scary warnings about this -- it should).

That's it! If you're more of a "follow a video" kind of person, here's a video demonstration of these steps:

[http://www.youtube.com/watch?v=_oaNbPOUCaE](http://www.youtube.com/watch?v=_oaNbPOUCaE)

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

Just go into your phone's Settings app, then go to "General->Profiles." Your CA will probably be the only thing listed under "Configuration Profiles." It will be listed as its "Common Name." Just click it and click "Remove" and it will be removed. (Thanks to [@tidegu](http://www.twitter.com/tidegu) for asking!)

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