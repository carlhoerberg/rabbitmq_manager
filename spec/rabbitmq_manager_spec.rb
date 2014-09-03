require './spec/spec_helper'
require './lib/rabbitmq_manager'

def create_manager
  RabbitMQManager.new 'http://guest:guest@localhost:15672'
end

RSpec.describe RabbitMQManager do
  before(:all) do
    @manager = create_manager
  end

  it "the overview method provides a Hash" do
    expect(@manager.overview()).to be_a Hash
  end

  it "there will be at least one connection" do
    items = @manager.connections()
    expect(items.length).to be >= 1
  end

  it "there will be at least one channel" do
    items = @manager.channels()
    expect(items.length).to be >= 1
  end

  describe "node discovery" do
    it "there will be at least one node" do
      items = @manager.nodes()
      expect(items.length).to be >= 1
    end
    it "" do
        hostname = `hostname`.chop
        item = @manager.node("rabbit@#{hostname}")
        expect(item).to be_a Hash
    end
  end

  it "all queues can be listed as an Array" do
    items = @manager.queues()
    expect(items).to be_an Array
  end

  it "queues can be listed per vhost as an Array" do
    items = @manager.queues('/')
    expect(items).to be_an Array
  end

  describe "queue manipulation" do
    queue = 'rspec-q1-' + rand(1000).to_s
    vhost = '/'

    after(:all) do
      @manager.queue_delete(vhost, queue)
    end

    it "queues can be created and removed" do
      @manager.queue_create(vhost, queue)
      items = @manager.queue(vhost, queue)
      expect(items).to be_a Hash
      expect(items['name']).to eq(queue)
    end
  end

  describe "when administering users and vhosts" do
    user = 'rspec-user-' + rand(1000).to_s
    passwd = rand(1000).to_s
    vhost = 'rspec-vh'

    before(:all) do
      @manager.user_create user, passwd
      @manager.vhost_create vhost
    end

    after(:all) do
      @manager.user_delete user
      @manager.vhost_delete vhost
    end

    it "list vhosts" do
      expect(@manager.vhosts.length).to be >= 2
    end

    it 'can view one vhost' do 
      expect(@manager.vhost(vhost)['name']).to eq(vhost)
    end

    it 'can list users' do 
      expect(@manager.users.length).to be >= 2
    end

    it 'can view one user' do 
      expect(@manager.user(user)['name']).to eq(user)
    end

    it 'cannot view an non existing user' do
      expect {
        @manager.user('foo')
      }.to raise_error Faraday::Error::ResourceNotFound
    end

    describe 'when administering users and vhosts' do
      users = []
      first = nil

      before(:all) do
        @manager.user_set_permissions(user, vhost, '.*', '.*', '.*')
        users = @manager.user_permissions(user)
        first = users.first
      end
      
      it 'user permissions is an Array' do
        expect(users).to be_an Array
      end

      it 'can read first users name' do
        expect(first['user']).to eq(user)
      end

      it 'first users has read permissions' do
        expect(first['read']).to eq('.*')
      end

      it 'first users has write permissions' do
        expect(first['write']).to eq('.*')
      end

    end

  end
end