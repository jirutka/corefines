describe Hash do
  using Corefines::Hash::only

  let(:hash) { {:one => 'ONE', 'two' => 'TWO', 3 => 'THREE'} }
  let!(:original) { hash.dup }

  let(:hash_with_proc) { Hash.new(&default_proc) }
  let(:default_proc) { proc {} }

  let(:hash_with_default) { Hash.new(default_value) }
  let(:default_value) { 42 }


  describe '#only' do

    context "existing keys" do
      it "returns a copy of the hash with only the specified keys" do
        expect( hash.only(:one, 3) ).to eq({:one => 'ONE', 3 => 'THREE'})
        expect( hash.only('two') ).to eq({'two' => 'TWO'})
      end
    end

    context "non-existing key" do
      it "returns an empty hash" do
        expect( hash.only(:x) ).to eq({})
      end
    end

    it "preserves the default_proc" do
      expect( hash_with_proc.only(:one).default_proc ).to equal default_proc
    end

    it "preserves the default" do
      expect( hash_with_default.only(:one).default ).to eq default_value
    end
  end


  describe '#only!' do

    context "existing keys" do
      it "removes all key/value pairs except the specified and returns the removed" do
        expect( hash.only!(:one, 3) ).to eq({'two' => 'TWO'})
        expect( hash ).to eq({:one => 'ONE', 3 => 'THREE'})
      end
    end

    context "non-existing key" do
      it "removes all key/value pairs and returns a copy of the original hash" do
        result = hash.only!(:x)
        expect( result ).to eq original
        expect( result ).to_not equal original
        expect( hash ).to eq({})
      end
    end

    it "preserves the default_proc" do
      expect( hash_with_proc.only!(:one).default_proc ).to equal default_proc
      expect( hash_with_proc.default_proc ).to equal default_proc
    end

    it "preserves the default" do
      expect( hash_with_default.only!(:one).default ).to eq default_value
      expect( hash_with_default.default ).to eq default_value
    end
  end
end
