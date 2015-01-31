describe Object do
  using Corefines::Object::then

  describe '#then' do

    it "calls the block and returns result" do
      expect('yay'.then { 42 }).to eq 42
    end

    it "passes self to the block" do
      'yay'.then { |x| expect(x).to eq 'yay' }
    end

    context "called on nil" do
      it "returns nil without calling the block" do
        expect(nil.then { fail }).to be_nil
      end
    end

    context "called on false" do
      it "returns false without calling the block" do
        expect(false.then { fail }).to be false
      end
    end
  end
end
