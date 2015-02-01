describe String do
  using Corefines::String::remove

  subject(:str) { "This is a good day to die" }
  let!(:original) { str.dup }

  describe '#remove' do

    context "string" do
      it "returns a new string with occurrences of the pattern removed" do
        expect(str.remove(" to die")).to eq "This is a good day"
        expect(str.remove("is")).to eq "Th  a good day to die"
        expect(str).to eq original
      end
    end

    context "regexp" do
      it "returns a new string with occurrences of the pattern removed" do
        expect(str.remove(/\s*to.*$/)).to eq "This is a good day"
        expect(str.remove(/\s/)).to eq "Thisisagooddaytodie"
        expect(str).to eq original
      end
    end

    context "multiple patterns" do
      it "returns a new string with occurrences of the patterns removed" do
        expect(str.remove("to die", /\s*$/)).to eq "This is a good day"
        expect(str.remove("to", "die", /\s*/)).to eq "Thisisagoodday"
        expect(str).to eq original
      end
    end
  end

  describe '#remove!' do

    context "string" do
      it "removes occurrences of the pattern and returns self" do
        expect(str.remove!(" to die")).to eq "This is a good day"
        expect(str.remove!("is")).to eq "Th  a good day"
      end
    end

    context "regexp" do
      it "removes occurrences of the pattern and returns self" do
        expect(str.remove!(/\s*to.*$/)).to eq "This is a good day"
        expect(str.remove!(/\s/)).to eq "Thisisagoodday"
      end
    end

    context "multiple patterns" do
      it "removes occurrences of the patterns and returns self" do
        expect(str.remove!("to die", /\s*$/)).to eq "This is a good day"
        expect(str.remove!("to", "die", /\s*/)).to eq "Thisisagoodday"
      end
    end
  end
end
