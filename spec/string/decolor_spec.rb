describe String do
  using Corefines::String::decolor

  describe '#decolor' do

    subject(:text) { "This is\nsome text" }

    context "colored text" do
      it "strips ANSI escape sequence" do
        expect("\e[1;34;42m#{text}\e[0m".decolor).to eq text
      end
    end

    context "concatenated colored texts" do
      it "strips all ANSI escape sequences" do
        text = "\e[0;39;42mSome\ncolored\e[0m\e[0;31;42m text\e[0m"
        expect(text.decolor).to eq "Some\ncolored text"
      end
    end

    context "plain string" do
      it "passes without change" do
        expect(text.decolor).to eq text
      end
    end
  end
end
