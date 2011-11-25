require 'cora'

class SiriProxy::Plugin < Cora::Plugin
  def request_completed
    self.manager.send_request_complete_to_iphone
  end
end