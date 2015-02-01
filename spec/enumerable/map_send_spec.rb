describe Enumerable do
  using Corefines::Enumerable::map_send

  describe '#map_send' do

    context Array do
      it "sends a message to each element and collects the result" do
        expect([1, 2, 3].map_send(:+, 3)).to eq [4, 5, 6]
      end
    end

    context Hash do
      it "sends a message to each element and collects the result" do
        expect({a: 1, b: 2}.map_send(:at, 1)).to eq [1, 2]
      end
    end

    context Set do
      it "sends a message to each element and collects the result" do
        expect(Set.new([1, 2, 3]).map_send(:+, 3)).to eq [4, 5, 6]
      end
    end
  end
end
