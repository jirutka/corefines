describe Object do
  using Corefines::Object::in?

  describe '#in?' do
    let(:other) { [] }

    it "returns true when argument includes self" do
      expect(other).to receive(:include?).with(42).and_return(true)
      expect(42.in? other).to be true
    end

    it "returns false when argument doesn't include self" do
      expect(other).to receive(:include?).with(66).and_return(false)
      expect(66.in? other).to be false
    end

    it "raises ArgumentError when argument doesn't respond #include?" do
      expect { 66.in? Object.new }.to raise_error ArgumentError
    end
  end
end
