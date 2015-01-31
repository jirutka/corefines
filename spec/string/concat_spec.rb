describe String do
  using Corefines::String::concat!

  describe '#concat!' do

    context "without separator" do
      subject { 'foo' }

      it "appends the given string to self" do
        subject.concat! 'bar'
        is_expected.to eq 'foobar'
      end
    end

    context "with separator" do

      context "when self is empty" do
        subject { '' }

        it "appends the given string to self" do
          subject.concat! 'bar', "\n"
          is_expected.to eq 'bar'
        end
      end

      context "when self is not empty" do
        subject { 'foo' }

        it "appends the given separator and string to self" do
          subject.concat! 'bar', "\n"
          is_expected.to eq "foo\nbar"
        end
      end
    end
  end
end
