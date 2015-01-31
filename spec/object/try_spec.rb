describe Object do
  using Corefines::Object::try

  let(:str) { "allons-y!" }

  describe '#try' do
    context "non-existing method" do
      it "returns nil" do
        expect(str.try(:non_existing_method)).to be_nil
      end
    end

    context "valid method" do
      it "calls and returns the result" do
        expect(str.try(:upcase)).to eq "ALLONS-Y!"
      end

      it "forwards arguments" do
        expect(str.try(:sub, '!', '?')).to eq "allons-y?"
      end

      it "forwards block" do
        expect(str.try(:sub, '!') { |m| '?' }).to eq "allons-y?"
      end
    end

    context "on nil" do
      it "returns nil" do
        expect(nil.try(:upcase)).to be_nil
      end
    end

    context "on false" do
      it "calls and returns the result" do
        expect(false.try(:to_s)).to eq 'false'
      end
    end
  end

  describe '#try!' do
    context "non-existing method" do
      it "raises NoMethodError" do
        expect { str.try!(:non_existing_method) }.to raise_error NoMethodError
      end
    end
  end
end
