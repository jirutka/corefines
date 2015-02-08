describe Hash do
  using Corefines::Hash::rekey

  let(:symbols) { {a: 1, b: 2, c: 3} }
  let(:strings) { {'a' => 1, 'b' => 2, 'c' => 3} }
  let(:mixed) { {'a' => 'foo', :b => 42, true => 66} }
  let(:mixed_symbolized) { {:a => 'foo', :b => 42, true => 66} }

  subject(:hash) { symbols }
  let!(:original) { hash.dup }


  describe '#rekey' do

    context "with no arguments" do
      subject(:hash) { mixed }

      it "returns a new hash with symbolized keys" do
        expect(hash.rekey).to eq mixed_symbolized
        expect(hash).to eql original
      end
    end

    context "with key_map" do
      it "returns a new hash with translated keys" do
        expect(hash.rekey(a: :x, c: 'y', d: 'z')).to eq({:x => 1, :b => 2, 'y' => 3})
        expect(hash).to eql original
      end
    end

    context "with block" do
      it "yields key and value to the block" do
        yielded = []
        hash.rekey { |k, v| yielded << [k, v] }
        expect(yielded).to eq [[:a, 1], [:b, 2], [:c, 3]]
      end

      it "returns a new hash with transformed keys" do
        expect(hash.rekey { |k| k.to_s }).to eq strings
        expect(hash).to eql original
      end
    end

    context "with symbol proc" do
      it "returns a new hash with transformed keys" do
        expect(hash.rekey(&:to_s)).to eq strings
        expect(hash).to eql original
      end
    end

    context "with both key_map and block" do
      it { expect { hash.rekey(a: 'x') { |k| k.to_s } }.to raise_error ArgumentError }
    end
  end


  describe '#rekey!' do

    context "with no arguments" do
      subject(:hash) { mixed }

      it "transforms keys to symbols and returns self" do
        expect(hash.rekey!).to eq mixed_symbolized
        expect(hash).to eq mixed_symbolized
      end
    end

    context "with key_map" do
      it "translates keys and returns self" do
        expected = {:x => 1, :b => 2, 'y' => 3}
        expect(hash.rekey!(a: :x, c: 'y', d: 'z')).to eq expected
        expect(hash).to eq expected
      end
    end

    context "with block" do
      it "yields key and value to the block" do
        yielded = []
        hash.rekey! { |k, v| yielded << [k, v] }
        expect(yielded).to eq [[:a, 1], [:b, 2], [:c, 3]]
      end

      it "transforms keys and returns self" do
        expect(hash.rekey! { |k| k.to_s }).to eq strings
        expect(hash).to eq strings
      end
    end

    context "with symbol proc" do
      it "transforms keys and returns self" do
        expect(hash.rekey!(&:to_s)).to eq strings
        expect(hash).to eq strings
      end
    end

    context "with key_map and block" do
      it { expect { hash.rekey!(a: 'x') { |k| k.to_s } }.to raise_error ArgumentError }
    end
  end
end
