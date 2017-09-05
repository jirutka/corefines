describe Hash do

  let(:hash) { {a: 1, b: 2, c: 4} }
  let!(:original) { hash.dup }

  let(:expected) { {a: '1', b: '2', c: '4'} }

  let(:hash_with_proc) { Hash.new(&default_proc) }
  let(:default_proc) { proc {} }

  let(:hash_with_default) { Hash.new(default_value) }
  let(:default_value) { 42 }


  describe '#map_values' do
    using Corefines::Hash::map_values

    context "with block" do
      it "returns a new hash with transformed values" do
        expect( hash.map_values(&:to_s) ).to eq expected
        expect( hash ).to eq original
      end

      # To be compatible with Hash#map_values in Ruby 2.4.
      it "does not preserve the default_proc" do
        expect( hash_with_proc.map_values(&:to_s).default_proc ).to be_nil
      end

      # To be compatible with Hash#map_values in Ruby 2.4.
      it "does not preserve the default" do
        expect( hash_with_default.map_values(&:to_s).default ).to be_nil
      end
    end

    context "with no arguments" do
      it "returns an Enumerator that produces a new hash with transformed values" do
        enum = hash.map_values
        expect( enum ).to be_a Enumerator
        expect( enum.each(&:to_s) ).to eq expected
        expect( hash ).to eq original
      end

      # To be compatible with Hash#map_values in Ruby 2.4.
      it "does not preserve the default_proc" do
        expect( hash_with_proc.map_values.each(&:to_s).default_proc ).to be_nil
      end

      # To be compatible with Hash#map_values in Ruby 2.4.
      it "does not preserve the default" do
        expect( hash_with_default.map_values.each(&:to_s).default ).to be_nil
      end
    end
  end


  describe '#map_values!' do
    using Corefines::Hash::map_values!

    context "with block" do
      it "transforms values and returns self" do
        expect( hash.map_values!(&:to_s) ).to eq expected
        expect( hash ).to eq expected
      end
    end

    context "with no arguments" do
      it "returns an Enumerator that transforms the values" do
        enum = hash.map_values!
        expect( enum ).to be_a Enumerator
        expect( enum.each(&:to_s) ).to eq expected
        expect( hash ).to eq expected
      end
    end
  end
end
