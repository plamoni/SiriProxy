require 'siri_proxy'
require 'siriObjectGenerator'

#######
# This is a "hello world" style plugin. It simply intercepts the phrase "text siri proxy" and responds
# with a message about the proxy being up and running. This is good base code for other plugins.
#
# Remember to add other plugins to the "start.rb" file if you create them!
######

class SiriProxy::Plugin::ExampleRedux < SiriProxy::Plugin

  listen_for /proxy/i do
    say "Siri proxy up and running!"
  end

end
