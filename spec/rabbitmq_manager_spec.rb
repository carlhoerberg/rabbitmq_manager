require './spec/spec_helper'
require './lib/rabbitmq_manager'

describe RabbitMQManager do
  let(:manager) { 
    RabbitMQManager.new 'http://guest:guest@localhost:15672'
  }

  context '#overview' do
    subject { manager.overview }
    it { should be_instance_of Hash }
  end

  context '#nodes' do 
    subject { manager.nodes }
    it { should have(1).things }
  end

  context '#queues' do
    subject { manager.queues }
    it { should be_instance_of Array }
  end

  context '#queues(vhost)' do
    subject { manager.queues('/') }
    it { should be_instance_of Array }
  end

  context '#queue' do
    let(:queue) { 'q1' }
    before { manager.queue_create('/', queue) }
    subject { manager.queue('/', queue) }
    it { should be_instance_of Hash }
    it { subject['name'].should == queue }
    after { manager.queue_delete('/', queue) }
  end

  context '#node' do
    let(:hostname) { `hostname -s`.chop }
    subject { manager.node("rabbit@#{hostname}") }
    it { should be_instance_of Hash }
  end

  context 'when administering users and vhosts' do
    let(:user)  { 'user1' }
    let(:passwd)  { 'rand123' }
    let(:vhost) { 'vh1' }

    before do
      manager.user_create user, passwd
      manager.vhost_create vhost
    end

    after do
      manager.user_delete user
      manager.vhost_delete vhost
    end
    
    it 'can list vhosts' do
      manager.vhosts.should have_at_least(2).things
    end

    it 'can view one vhost' do 
      manager.vhost(vhost)['name'].should == vhost
    end

    it 'can list users' do 
      manager.users.should have_at_least(2).things
    end

    it 'can view one user' do 
      manager.user(user)['name'].should == user
    end

    it 'cannot view an non existing user' do
      lambda {
        manager.user('foo')
      }.should raise_error Faraday::Error::ResourceNotFound
    end

    context 'permissions' do
      before  { manager.user_set_permissions(user, vhost, '.*', '.*', '.*') }
      subject { manager.user_permissions(user) }
      it { subject.should be_instance_of Array }
      context 'for first element' do
        subject { manager.user_permissions(user).first }
        it('has name') { subject['user'] == user }
        it('has read permissions') { subject['read'] == '.*' }
        it('has write permissions') { subject['write'] == '.*' }
      end
    end
  end
end
