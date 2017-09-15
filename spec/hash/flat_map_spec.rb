require 'ostruct'

describe Hash do
  describe '#flat_map' do
    using Corefines::Hash::flat_map

    let(:hash) { {a: 1, b: 2, c: 3} }
    let!(:original) { hash.dup }

    context "with block" do
      it "returns a new hash, does not mutate self" do
        expect( hash.flat_map { |k, v| {k => v * 2} } ).to be_a Hash
        expect( hash ).to eq original
      end

      context "that yields Hash" do
        it "returns merged results of running block for each entry" do
          expect( hash.flat_map { |k, v| {k => v * 2, k.upcase => v * 3} } )
            .to eq({a: 2, A: 3, b: 4, B: 6, c: 6, C: 9})
        end

        it "does not flatten yielded hashes" do
          expect( hash.flat_map { |k, v| {k => {k.upcase => v}} } )
            .to eq({a: {A: 1}, b: {B: 2}, c: {C: 3}})
        end

        it "omits entries for which the block yielded nil" do
          expect( hash.flat_map { |k, v| {k.upcase => v * 2} if k != :b } )
            .to eq({A: 2, C: 6})
        end

        it "handles duplicated keys by method the last wins" do
          expect( hash.flat_map { |k, v| {k => v * 2, b: v * 6} } )
            .to eq({a: 2, b: 18, c: 6})
        end
      end

      context "that yields Array" do
        it "interprets array of pairs as Hash" do
          expect( hash.flat_map { |k, v| [[k, v * 2], [k.upcase, v * 3]] } )
            .to eq({a: 2, A: 3, b: 4, B: 6, c: 6, C: 9})
        end

        it "raises ArgumentError if nested array has more than 2 elements" do
          expect { hash.flat_map { |k, v| [[k, v, v]] } }.to raise_error(ArgumentError)
        end
      end

      # There's no usable class in 1.9.3 implementing #to_h and I'd like to
      # keep this simple...
      if RUBY_VERSION.to_f >= 2
        context "that yields object responding to #to_h" do
          it "calls #to_h on yielded value" do
            expect( hash.flat_map { |k, v| OpenStruct.new(k => v * 2) } )
              .to eq({a: 2, b: 4, c: 6})
          end
        end
      end
    end
  end
end
