require "rabbitmq_manager/version"
require 'faraday'
require 'faraday_middleware'
require 'uri'

class RabbitMQManager
  def initialize(url)
    headers = { 
      'accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
    @conn = Faraday.new(:url => url, :headers => headers) do |builder|
      builder.use Faraday::Response::RaiseError
      builder.use FaradayMiddleware::EncodeJson
      builder.use FaradayMiddleware::ParseJson, :content_type => /\bjson$/
      builder.adapter Faraday.default_adapter
    end
  end

  def overview
    @conn.get('/api/overview').body
  end

  def nodes
    @conn.get('/api/nodes').body
  end

  def node(name)
    @conn.get("/api/nodes/#{URI.escape name}").body
  end

  def vhosts
    @conn.get('/api/vhosts').body
  end

  def vhost(name)
    @conn.get("/api/vhosts/#{URI.escape name}").body
  end

  def vhost_create(name)
    @conn.put("/api/vhosts/#{URI.escape name}").body
  end

  def vhost_delete(name)
    @conn.delete("/api/vhosts/#{URI.escape name}").body
  end

  def users
    @conn.get('/api/users').body
  end

  def user(name)
    @conn.get("/api/users/#{URI.escape name}").body
  end

  def user_create(name, password, tags = '')
    @conn.put("/api/users/#{URI.escape name}", {
      :password => password, 
      :tags => tags 
    }).body
  end

  def user_delete(name)
    @conn.delete("/api/users/#{URI.escape name}").body
  end

  def user_set_permissions(name, vhost, configure, write, read)
    @conn.put("/api/permissions/#{URI.escape vhost}/#{URI.escape name}", {
      :configure => configure,
      :write => write, 
      :read => read
    }).body
  end

  def user_permissions(name)
    @conn.get("/api/users/#{URI.escape name}/permissions").body
  end
end
