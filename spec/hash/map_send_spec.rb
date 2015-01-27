describe Hash do
  using Corefines::Hash::map_send

  describe '#map_send' do
    it "sends a message to each element and collects the result" do
      expect({a: 1, b: 2}.map_send(:at, 1)).to eq [1, 2]
    end
  end
end
