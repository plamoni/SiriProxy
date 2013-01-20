require 'cora'
require 'siri_objects'
require 'pp'
require 'dbus'

#######
# A simple SiriProxy plugin that controls the Rhythmbox music player using D-Bus
######

class SiriProxy::Plugin::Rhythmbox < SiriProxy::Plugin
  def initialize(config)
    #if you have custom configuration options, process them here!
  end

  @iface

  def iface
    if @iface.nil?
      begin
        bus = DBus::SessionBus.instance
        service = bus["org.mpris.MediaPlayer2.rhythmbox"]
        object = service.object("/org/mpris/MediaPlayer2")
        object.introspect
        @iface = object["org.mpris.MediaPlayer2.Player"]
      rescue Exception=>e
        say "Player is not running"
      end
    end
    @iface
  end

  listen_for /start player/i do
    say "Starting player"
    if fork.nil?
      exec("rhythmbox")
    end
    request_completed
  end

  listen_for /play/i do
    unless iface.nil?
      iface.PlayPause
      title = iface["Metadata"]["xesam:title"]
      artist = iface["Metadata"]["xesam:artist"]
      say "Playing music #{title} from #{artist}"
      request_completed
    end
  end

  listen_for /pause/i do
    unless iface.nil?
      title = iface["Metadata"]["xesam:title"]
      artist = iface["Metadata"]["xesam:artist"]
      say "Pausing music #{title} from #{artist}"
      iface.Pause
    end
    request_completed
  end

  listen_for /stop/i do
    unless iface.nil?
      title = iface["Metadata"]["xesam:title"]
      artist = iface["Metadata"]["xesam:artist"]
      say "Stoping music #{title} from #{artist}"
      iface.Stop
    end
    request_completed
  end

  listen_for /next/i do
    unless iface.nil?
      iface.Next
      title = iface["Metadata"]["xesam:title"]
      artist = iface["Metadata"]["xesam:artist"]
      say "Next music is #{title} from #{artist}"
    end
    request_completed
  end

  listen_for /previous/i do
    unless iface.nil?
      iface.Previous
      title = iface["Metadata"]["xesam:title"]
      artist = iface["Metadata"]["xesam:artist"]
      say "Previous is #{title} from #{artist}"
    end
    request_completed
  end

  listen_for /shuffle on/i do
    unless iface.nil?
      iface["Shuffle"] = true
      say "Turning shuffle mode on"
    end
    request_completed
  end

  listen_for /shuffle off/i do
    unless iface.nil?
      iface["Shuffle"] = false
      say "Turning shuffle mode off"
    end
    request_completed
  end

  listen_for /volume up/i do
    unless iface.nil?
      volume = iface["Volume"]
      if volume + 0.2 <= 1
        volume += 0.2
        iface["Volume"] = volume
        say "Turning volume up by 20%"
      else
        say "Volume is already at maximum level"
      end
    end
    request_completed
  end

  listen_for /volume down/i do
    unless iface.nil?
      volume = iface["Volume"]
      if volume - 0.2 >= 0
        volume -= 0.2
        iface["Volume"] = volume
        say "Turning volume down by 20%"
      else
        say "Volume is already at minimum level"
      end
    end
      request_completed
  end

end
