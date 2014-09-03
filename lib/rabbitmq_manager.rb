require "rabbitmq_manager/version"
require 'faraday'
require 'faraday_middleware'
require 'uri'

class RabbitMQManager
  def initialize(url, ssl_options = nil)
    opts = {
      :headers => {
        'accept' => 'application/json',
        'Content-Type' => 'application/json'
      },
      :ssl => ssl_options
    }

    @conn = Faraday::Connection.new(url, opts) do |builder|
      builder.use Faraday::Response::RaiseError
      builder.use FaradayMiddleware::EncodeJson
      builder.use FaradayMiddleware::ParseJson, :content_type => /\bjson$/
      builder.adapter Faraday.default_adapter
    end
  end

  def overview
    @conn.get(url :overview).body
  end

  def connections
    @conn.get(url :connections).body
  end

  def channels
    @conn.get(url :channels).body
  end

  def policies(vhost = '')
    @conn.get(url :policies, vhost).body
  end

  def policy_get(vhost, name)
    @conn.get(url :policies, vhost, name).body
  end

  def policy_create(vhost, name, pattern, definition, opts = nil)
    valid = ["ha-mode", "ha-params", "ha-sync-mode", "alternate-exchange", "dead-letter-exchange","dead-letter-routing-key", "message-ttl", "expires", "max-length", "federation-upstream-set"]
    definition.keys.each { | key |
      if !valid.include?(key)
        raise "The definition key '#{key}' is not valid, try these #{valid}"
      end
    }
    policy = {
      pattern: pattern,
      definition: definition
    }.merge(opts || {})

    @conn.put(url(:policies, vhost, name), policy).body
  end

  def policy_delete(vhost, name)
    @conn.delete(url :policies, vhost, name).body
  end

  def queues(vhost = '')
    @conn.get(url :queues, vhost).body
  end

  def queue(vhost, name)
    @conn.get(url :queues, vhost, name).body
  end

  def queue_create(vhost, name, durable = false, auto_delete = false, args = {})
    opts = { durable: durable, auto_delete: auto_delete, arguments: args }
    @conn.put(url(:queues, vhost, name), opts).body
  end

  def queue_delete(vhost, name)
    @conn.delete(url :queues, vhost, name).body
  end

  def nodes
    @conn.get(url :nodes).body
  end

  def node(name)
    @conn.get(url :nodes, name).body
  end

  def vhosts
    @conn.get(url :vhosts).body
  end

  def vhost(name)
    @conn.get(url :vhosts, name).body
  end

  def vhost_create(name)
    @conn.put(url :vhosts, name).body
  end

  def vhost_delete(name)
    @conn.delete(url :vhosts, name).body
  end

  def users
    @conn.get(url :users).body
  end

  def user(name)
    @conn.get(url :users, name).body
  end

  def user_create(name, password, tags = '')
    @conn.put(url(:users, name), {
      :password => password,
      :tags => tags
    }).body
  end

  def user_delete(name)
    @conn.delete(url :users, name).body
  end

  def user_set_permissions(name, vhost, configure, write, read)
    @conn.put(url(:permissions, vhost, name), {
      :configure => configure,
      :write => write,
      :read => read
    }).body
  end

  def user_permissions(name)
    @conn.get(url :users, name, :permissions).body
  end

  private
  def url(*args)
    '/api/' + args.map{ |a| URI.encode_www_form_component a.to_s }.join('/')
  end
end
