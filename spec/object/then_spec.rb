describe Object do
  using Corefines::Object::then

  describe '#then' do

    it "calls the block and returns result" do
      expect('yay'.then { 42 }).to eq 42
    end

    it "passes self to the block" do
      expect('yay'.then { |x| x + '!' }).to eq 'yay!'
    end

    context "called on nil" do
      it "returns nil without calling block" do
        expect(nil.then { fail }).to be_nil
      end
    end

    context "called on false" do
      it "calls the block and returns result" do
        expect(false.then { |x| 42 unless x }).to eq 42
      end
    end
  end
end
