require 'mock_redis'
require_relative '../../app/models/redis_client'

describe RedisClient do
  let(:redis_client) { RedisClient.new }
  let(:mock_redis) { RedisClient.class_variable_set :@@redis_conn, MockRedis.new }
  let(:incident) { Incident.new }

  context 'redis is online' do
    before do
      redis_client
      mock_redis
    end

    it 'should have a verified connection' do
      expect(redis_client.connection_verified?).to be_truthy
    end

    it 'should write to redis successfully' do
      expect(redis_client.upsert(incident)).to be_truthy
    end
  end

  context 'redis is offline' do
    before do
      redis_client
      mock_redis
      allow(redis_client).to receive(:connection_verified?) { false }
    end

    it 'should have no connection' do
      expect(redis_client.connection_verified?).to be_falsey
    end

    it 'should gracefully handle attempts to store data when offline' do
      expect(redis_client.upsert(incident)).to be_falsey
    end
  end
end