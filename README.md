Siri Proxy
==========

About
-----
Siri Proxy is a proxy server for Apple's Siri "assistant." The idea is to allow for the creation of custom handlers for different actions. This can allow developers to easily add functionality to Siri. 

The main example I provide is a plugin to control [my thermostat](http://www.radiothermostat.com/latestnews.html#advanced) with Siri. It responds to commands such as, "What's the status of the thermostat?", or "Set the thermostat to 68 degrees", or even "What's the inside temperature?"

Set-up Instructions
-------------------

Currently, setup requires a pretty solid knowledge of certificates and openssl (or some good skills with Google). I'll see about providing automated scripts for generating the CA and relavent cert soon.

1. Create a root CA using open SSL and have it issue a signed certificate for guzzoni.apple.com. Save the guzzoni private key (no passphrase) and certificate as "server.passless.key" and "server.passless.crt" in the SiriProxy directory.
2. Load the root CA's public certificate on your phone (you can just email it to yourself and click it to do that).
3. Set up a DNS server on your network to forward requests for guzzoni.apple.com to the computer running the proxy (make sure that computer is not using your DNS server!). I recommend dnsmasq for this purpose. It's easy to get running and can easily handle this sort of behavior.
4. Install the requisite Ruby gems:
	* httparty
	* open-uri
	* json
	* CFPropertyList
	* pp
	* uuidtools
5. Execute start.rb (as root -- since it must listen on TCP/443)
6. Activate Siri on your phone (connected to the network and using the DNS server with the fake entry), and say, "Test Siri proxy." It should respond, "Siri Proxy is up and running!"

Acknowledgements
----------------
I really can't give enough credit to [Applidium](http://applidium.com/en/news/cracking_siri/) and the [tools they created](https://github.com/applidium/Cracking-Siri). While I've been toying with Siri for a while, their proof of concept for intercepting and interpreting the Siri protocol was invaluable. Although all the code included in the project (so far) is my own, much of the base logic behind my code is based on the sample code they provided. They do great work.


Disclaimer
----------
I'm not affiliated with Apple in any way. They don't endorse this application. They own all the rights to Siri (and all associated trademarks). 

This software is provided as-is with no warranty whatsoever. Apple could do things to block this kind of behavior if they want. Also, if you cause problems (by sending lots of trash to the Guzzoni servers or anything), I fully support Apple's right to ban your UIUD (making your phone unable to use Siri). They can, and I wouldn't blame them if they do.

I'm a huge fan of Apple and the work that they do. Siri is a very cool feature and I'm pretty excited to explore it and add functionality. Please refrain from using this software for anything malicious.

Also, this is my first project done in Ruby. Please don't be too critical of my code.