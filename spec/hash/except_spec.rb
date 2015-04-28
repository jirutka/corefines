describe Hash do
  using Corefines::Hash::except

  subject(:hash) { {:one => 'ONE', 'two' => 'TWO', 3 => 'THREE'} }

  let(:hash_with_proc) { Hash.new(&default_proc) }
  let(:default_proc) { proc {} }

  let(:hash_with_default) { Hash.new(default_value) }
  let(:default_value) { 42 }


  describe '#except' do

    context "existing keys" do
      it "returns a copy of the hash without the specified keys" do
        expect( hash.except(:one, 3) ).to eql({'two' => 'TWO'})
        expect( hash.except('two') ).to eql({:one => 'ONE', 3 => 'THREE'})
      end
    end

    context "non-existing key" do
      it "returns a copy of the hash unchanged" do
        expect( hash.except(:x) ).to eql hash
        expect( hash.except(:x) ).to_not equal(hash)
      end
    end

    it "preserves the default_proc" do
      expect( hash_with_proc.except(:one).default_proc ).to equal default_proc
    end

    it "preserves the default" do
      expect( hash_with_default.except(:one).default ).to eq default_value
    end
  end


  describe '#except!' do

    context "existing keys" do
      it "removes the specified keys/value pairs and returns them" do
        expect( hash.except!(:one, 3) ).to eql({:one => 'ONE', 3 => 'THREE'})
        is_expected.to eq({'two' => 'TWO'})
      end
    end

    context "non-existing key" do
      it "keeps the hash unchanged and returns an empty hash" do
        expect( hash.except!(:x) ).to eq({})
        expect( hash ).to equal hash
      end
    end

    it "preserves the default_proc" do
      expect( hash_with_proc.except!(:one).default_proc ).to equal default_proc
      expect( hash_with_proc.default_proc ).to equal default_proc
    end

    it "preserves the default" do
      expect( hash_with_default.except!(:one).default ).to eq default_value
      expect( hash_with_default.default ).to eq default_value
    end
  end
end
