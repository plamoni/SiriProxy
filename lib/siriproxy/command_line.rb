require 'optparse'
require 'yaml'
require 'ostruct'

# @todo want to make SiriProxy::Commandline without having to
# require 'siriproxy'. Im sure theres a better way.
class SiriProxy

end

class SiriProxy::CommandLine
  $LOG_LEVEL = 0
  
  BANNER = <<-EOS
Siri Proxy is a proxy server for Apple's Siri "assistant." The idea is to allow for the creation of custom handlers for different actions. This can allow developers to easily add functionality to Siri.

See: http://github.com/plamoni/SiriProxy/

Usage: siriproxy COMMAND OPTIONS

Commands:
server            Start up the Siri proxy server
gencerts          Generate a the certificates needed for SiriProxy
bundle            Install any dependancies needed by plugins
console           Launch the plugin test console 
update [dir]      Updates to the latest code from GitHub or from a provided directory
help              Show this usage information

Options:
    Option                           Command       Description
  EOS

  def initialize
    @branch = nil
    parse_options
    command     = ARGV.shift
    subcommand  = ARGV.shift
    case command
    when 'server'           then run_server(subcommand)
    when 'gencerts'         then gen_certs
    when 'bundle'           then run_bundle(subcommand)
    when 'console'          then run_console
    when 'update'           then update(subcommand)
    when 'help'             then usage
    when 'dnsonly'          then dns
    else                    usage
    end
  end

  def run_console
    load_code
    init_plugins

    # this is ugly, but works for now
    SiriProxy::PluginManager.class_eval do
      def respond(text, options={})
        puts "=> #{text}"
      end
      def process(text)
        super(text)
      end
      def send_request_complete_to_iphone
      end
      def no_matches
        puts "No plugin responded"
      end
    end
    SiriProxy::Plugin.class_eval do
      def last_ref_id
        0
      end
      def send_object(object, options={:target => :iphone})
        puts "=> #{object}"
      end
    end

    cora = SiriProxy::PluginManager.new
    repl = -> prompt { print prompt; cora.process(gets.chomp!) }
    loop { repl[">> "] }
  end

  def run_bundle(subcommand='')
    setup_bundler_path
    puts `bundle #{subcommand} #{ARGV.join(' ')}`
  end

  def run_server(subcommand='start')
    load_code
    init_plugins
    start_server
    # @todo: support for forking server into bg and start/stop/restart
    # subcommand ||= 'start'
    # case subcommand
    # when 'start'    then start_server
    # when 'stop'     then stop_server
    # when 'restart'  then restart_server
    # end
  end

  def start_server
    if $APP_CONFIG.server_ip
      require 'siriproxy/dns'
      dns_server = SiriProxy::Dns.new
      dns_server.start()
    end
    proxy = SiriProxy.new
    proxy.start()
  end

  def gen_certs
    ca_name = @ca_name ||= ""
    command = File.join(File.dirname(__FILE__), '..', "..", "scripts", 'gen_certs.sh')
    sp_root = File.join(File.dirname(__FILE__), '..', "..")
    puts `#{command} "#{sp_root}" "#{ca_name}"`
  end

  def update(directory=nil)
    if(directory)
      puts "=== Installing from '#{directory}' ==="
      puts `cd #{directory} && rake install`
      puts "=== Bundling ===" if $?.exitstatus == 0
      puts `siriproxy bundle` if $?.exitstatus == 0
      puts "=== SUCCESS ===" if $?.exitstatus == 0
      
      exit $?.exitstatus
    else
      branch_opt = @branch ? "-b #{@branch}" : ""
      @branch = "master" if @branch == nil
      puts "=== Installing latest code from git://github.com/plamoni/SiriProxy.git [#{@branch}] ==="

	  tmp_dir = "/tmp/SiriProxy.install." + (rand 9999).to_s.rjust(4, "0")

	  `mkdir -p #{tmp_dir}`
      puts `git clone #{branch_opt} git://github.com/plamoni/SiriProxy.git #{tmp_dir}`  if $?.exitstatus == 0
      puts "=== Performing Rake Install ===" if $?.exitstatus == 0
      puts `cd #{tmp_dir} && rake install`  if $?.exitstatus == 0
      puts "=== Bundling ===" if $?.exitstatus == 0
      puts `siriproxy bundle`  if $?.exitstatus == 0
      puts "=== Cleaning Up ===" and puts `rm -rf #{tmp_dir}` if $?.exitstatus == 0
      puts "=== SUCCESS ===" if $?.exitstatus == 0

      exit $?.exitstatus
    end 
  end

  def dns
    require 'siriproxy/dns'
    $APP_CONFIG.use_dns = true
    server = SiriProxy::Dns.new
    server.run(Logger::DEBUG)
  end

  def usage
    puts "\n#{@option_parser}\n"
  end

  private
  
  def parse_options
    config_file = File.expand_path(File.join('~', '.siriproxy', 'config.yml'));

    unless File.exists?(config_file)
      default_config = config_file
      config_file = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config.example.yml'))
    end

    $APP_CONFIG = OpenStruct.new(YAML.load_file(config_file))

    # Google Public DNS servers
    $APP_CONFIG.upstream_dns ||= %w[8.8.8.8 8.8.4.4]

    @branch = nil
    @option_parser = OptionParser.new do |opts|
      opts.on('-d', '--dns ADDRESS',     '[server]      Launch DNS server guzzoni.apple.com with ADDRESS (requires root)') do |ip| 
        $APP_CONFIG.server_ip = ip
      end
      opts.on('-l', '--log LOG_LEVEL',   '[server]      The level of debug information displayed (higher is more)') do |log_level|
        $APP_CONFIG.log_level = log_level
      end
      opts.on('-L', '--listen ADDRESS',  '[server]      Address to listen on (central or node)') do |listen|
        $APP_CONFIG.listen = listen
      end
      opts.on('-D', '--upstream-dns SERVERS', Array, '[server]      List of upstream DNS servers to use.  Defaults to \'[8.8.8.8, 8.8.4.4]\'') do |servers|
        $APP_CONFIG.upstream_dns = servers
      end
      opts.on('-p', '--port PORT',       '[server]      Port number for server (central or node)') do |port_num|
        $APP_CONFIG.port = port_num
      end
      opts.on('-u', '--user USER',       '[server]      The user to run as after launch') do |user|
        $APP_CONFIG.user = user
      end
      opts.on('-b', '--branch BRANCH',   '[update]      Choose the branch to update from (default: master)') do |branch|
        @branch = branch
      end
      opts.on('-n', '--name CA_NAME',    '[gencerts]    Define a common name for the CA (default: "SiriProxyCA")') do |ca_name|
        @ca_name = ca_name
      end 
      opts.on_tail('-v', '--version',  '              Show version') do
        require "siriproxy/version"
        puts "SiriProxy version #{SiriProxy::VERSION}"
        exit
      end
    end
    @option_parser.banner = BANNER
    @option_parser.parse!(ARGV)
  end

  def setup_bundler_path
    require 'pathname'
    ENV['BUNDLE_GEMFILE'] ||= File.expand_path("../../../Gemfile",
      Pathname.new(__FILE__).realpath)
  end

  def load_code
    setup_bundler_path

    require 'bundler'
    require 'bundler/setup'

    require 'siriproxy'
    require 'siriproxy/connection'
    require 'siriproxy/connection/iphone'
    require 'siriproxy/connection/guzzoni'

    require 'siriproxy/plugin'
    require 'siriproxy/plugin_manager'
  end
  
  def init_plugins
    pManager = SiriProxy::PluginManager.new
    pManager.plugins.each_with_index do |plugin, i|
      if plugin.respond_to?('plugin_init')                                                                     
        $APP_CONFIG.plugins[i]['init'] = plugin.plugin_init
      end
    end
    pManager = nil
  end
end
