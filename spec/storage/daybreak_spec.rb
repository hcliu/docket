require 'spec_helper'

describe Docket::Storage::Daybreak do

  describe '#new' do
    it 'creates the storage backend' do
      expect($storage.db).to_not be_nil
    end
  end

  describe '#save' do
    it 'saves the key to the db' do
      $storage.save 'key1', 'value1'

      expect($storage.db.get('key1')).to eql('value1')
    end

    it 'compacts the db to only have one key' do
      $storage.send(:clear!)

      $storage.save 'key1', 'value1'
      reload_storage_connection
      
      $storage.save 'key1', 'value2'

      expect($storage.db.keys.size).to eql(1)
    end
  end

  describe '#read' do
    it 'returns value set for key in db' do
      $storage.save 'key1', 'value1'
      expect($storage.read('key1')).to eql('value1')
    end
  end

  describe '#append' do
    context 'key does not exist' do
      it 'creates key and appends' do
        $storage.append 'append_key', 2

        reload_storage_connection
        

        expect($storage.read('append_key')).to eql([2])
      end
    end

    context 'key exists' do

      it "appends value to the end of a list value for key" do
        $storage.save 'key1', [1]
        $storage.append 'key1', 2

        reload_storage_connection


        expect($storage.read('key1')).to eql([1,2])
      end
    end
    
  end

end
