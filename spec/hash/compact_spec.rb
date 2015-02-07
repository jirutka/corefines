describe Hash do
  using Corefines::Hash::compact

  let!(:original) { subject.dup }

  describe '#compact' do

    context "hash with some nil values" do
      subject(:hash) { {a: true, b: false, c: nil, d: 'foo'} }

      it "returns a new hash with no key-value pairs which value is nil" do
        expect(hash.compact).to eq({a: true, b: false, d: 'foo'})
        expect(hash).to eql original
      end
    end

    context "hash with only nil values" do
      subject(:hash) { {a: nil, b: nil} }

      it "returns a new empty hash" do
        expect(hash.compact).to be_empty
        expect(hash).to eql original
      end
    end
  end

  describe '#compact!' do

    context "hash with some nil values" do
      subject(:hash) { {a: true, b: false, c: nil, d: 'foo'} }
      let(:expected) { {a: true, b: false, d: 'foo'} }

      it "removes key-value pairs which value is nil" do
        expect(hash.compact!).to eq expected
        expect(hash).to eq expected
      end
    end

    context "hash with only nil values" do
      subject(:hash) { {a: nil, b: nil} }

      it "removes all key-value pairs" do
        expect(hash.compact!).to be_empty
        expect(hash).to be_empty
      end
    end
  end
end
