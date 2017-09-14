describe Hash do
  describe '#recurse' do
    using Corefines::Hash::recurse

    subject(:hash) { {a: 1, b: {d: {f: 6}, e: 5}, c: 3} }
    let(:expected) { {a: 1, b: {d: {f: 6, x: 42}, e: 5, x: 42}, c: 3, x: 42} }
    let!(:original) { Marshal.load(Marshal.dump(hash)) }  # deep clone

    shared_examples :common do
      it "returns a result of calling block on the hash and sub-hashes recursively" do
        is_expected.to eq expected
      end
    end

    context "with pure block" do
      subject!(:result) { hash.recurse { |h| h.merge(x: 42) } }

      include_examples :common

      it "does not mutate the original hash" do
        expect( hash ).to eq original
      end
    end

    context "with impure block" do
      subject!(:result) { hash.recurse { |h| h.merge!(x: 42) } }

      include_examples :common

      it "modifies the hash in-place" do
        expect( hash ).to eq expected
        expect( hash ).to_not eq original
      end
    end
  end
end
