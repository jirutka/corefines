describe Array do
  using Corefines::Array::map_send

  describe '#map_send' do
    it "sends a message to each element and collects the result" do
      expect([1, 2, 3].map_send(:+, 3)).to eq [4, 5, 6]
    end
  end
end
