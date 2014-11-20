require './spec/spec_helper'
require './lib/rabbitmq_manager'

def make_name(name_prefix)
  name_prefix + '-' + rand(1000).to_s
end

RSpec.describe RabbitMQManager do
  before(:all) do
    @rspec_user = 'guest'
    rspec_password = 'guest'
    @manager = RabbitMQManager.new "http://#{@rspec_user}:#{rspec_password}@localhost:15672"
  end

  it 'the overview method provides a Hash' do
    expect(@manager.overview()).to be_a Hash
  end

  it 'there will be at least one connection' do
    items = @manager.connections()
    expect(items.length).to be >= 1
  end

  it 'there will be at least one channel' do
    items = @manager.channels()
    expect(items.length).to be >= 1
  end

  describe 'node discovery' do
    it 'there will be at least one node' do
      items = @manager.nodes()
      expect(items.length).to be >= 1
    end
    it 'the list of nodes is a Hash' do
        hostname = `hostname`.chop
        item = @manager.node("rabbit@#{hostname}")
        expect(item).to be_a Hash
    end
  end

  it 'all queues can be listed as an Array' do
    items = @manager.queues()
    expect(items).to be_an Array
  end

  it 'queues can be listed per vhost as an Array' do
    items = @manager.queues('/')
    expect(items).to be_an Array
  end

  describe 'queue manipulation' do
    queue = make_name 'rspec-q1'
    vhost = '/'

    after(:all) do
      @manager.queue_delete(vhost, queue)
    end

    it 'queues can be created and removed' do
      @manager.queue_create(vhost, queue)
      items = @manager.queue(vhost, queue)
      expect(items).to be_a Hash
      expect(items['name']).to eq(queue)
    end
  end

  describe 'when administering users and vhosts' do
    user = make_name 'rspec-user'
    passwd = make_name ''
    vhost = 'rspec-vh'

    before(:all) do
      @manager.user_create user, passwd
      @manager.vhost_create vhost
    end

    after(:all) do
      @manager.user_delete user
      @manager.vhost_delete vhost
    end

    it 'list vhosts' do
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

  describe 'high availability policies can be administered' do
    vhost = make_name 'rspec-vh'

    before(:each) do
      @manager.vhost_create(vhost)
      @manager.user_set_permissions(@rspec_user, vhost, '.*', '.*', '.*')
    end

    after(:each) do
      @manager.vhost_delete(vhost)
    end

    it 'initially a specific vhost has no policies, the Array is empty' do
      policies = @manager.policies(vhost)
      expect(policies).to be_an Array
      expect(policies.length).to eq(0)
    end

    it 'Creating a basic policy requires a name, pattern and a definition' do
      name = make_name 'rspec-policy'
      @manager.policy_create(vhost, name, '^None', {'ha-mode'=>'all'})
      policies = @manager.policies(vhost)
      expect(policies.length).to eq(1)
    end

    it 'individual policies can be queried' do
      name = make_name 'rspec-policy'
      @manager.policy_create(vhost, name, '^None', {'ha-mode'=>'all'})
      policy = @manager.policy_get(vhost, name)
      
      expect(policy['name']).to eq(name)
    end

    it 'individual policies can be deleted' do
      name = make_name 'rspec-policy'

      @manager.policy_create(vhost, name, '^None', {'ha-mode'=>'all'})
      @manager.policy_delete(vhost, name)

      expect(@manager.policies(vhost).length).to eq(0)
    end

    it 'queries on a non-existent policy throws and error' do
      name = make_name 'rspec-policy'
      expect {
        @manager.policy_get(vhost, name)
      }.to raise_error Faraday::Error::ResourceNotFound
    end

  end
end