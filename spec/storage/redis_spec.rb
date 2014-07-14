require 'spec_helper'
require "fakeredis"

describe Docket::Storage::Redis do

  let(:redis_storage) { Docket::Storage::Redis.new(:redis => Redis.new) }

  describe '#new' do
    it 'creates the storage backend' do
      expect(redis_storage.db).to_not be_nil
    end
  end

  describe '#save' do
    it 'saves the key to the db' do
      redis_storage.save 'key1', 'value1'

      expect(redis_storage.read('key1')).to eql('value1')
    end
  end

  describe '#read' do
    it 'returns value set for key in db' do
      redis_storage.save 'key1', 'value1'
      expect(redis_storage.read('key1')).to eql('value1')
    end
  end

  describe '#append' do
    context 'key does not exist' do
      it 'creates key and appends' do
        redis_storage.clear!
        redis_storage.append 'append_key', 2
        expect(redis_storage.read('append_key')).to eql([2])
      end
    end

    context 'key exists' do

      it "appends value to the end of a list value for key" do
        redis_storage.clear!
        redis_storage.append 'key1', 1
        redis_storage.append 'key1', 2

        expect(redis_storage.read('key1')).to eql([1,2])
      end
    end
    
  end
  
end
