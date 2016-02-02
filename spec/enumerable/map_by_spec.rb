describe Enumerable do
  using Corefines::Enumerable::map_by

  describe '#map_by' do

    context Array do
      let(:input) { [1, 2, 3, 4, 5] }
      let(:expected) { { 0 => [3, 5], 1 => [2, 4, 6] } }

      it "returns hash with the elements grouped and mapped by result of the block" do
        expect(input.map_by { |e| [e % 2, e + 1] }).to eq expected
      end
    end

    context Hash do
      let(:input) { { "Lucy" => 86, "Ruby" => 98, "Drew" => 94, "Lisa" => 54 } }
      let(:expected) {  { "A" => ["Ruby", "Drew"], "B" => ["Lucy"], "F" => ["Lisa"] } }

      it "returns hash with the elements grouped and mapped by result of the block" do
        expect(input.map_by { |k, v| [score(v), k] }).to eq expected
      end

      def score(n)
        n < 70 ? 'F' : n < 80 ? 'C' : n < 90 ? 'B' : 'A'
      end
    end
  end
end
