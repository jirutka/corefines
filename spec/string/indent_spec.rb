describe String do
  using Corefines::String::indent

  describe '#indent' do

    context "with default indent_str" do
      context "string already indented with spaces" do
        it "indents with spaces" do
          expect( "foo\n  bar".indent(2) ).to eql "  foo\n    bar"
        end
      end

      context "string already indented with tabs" do
        it "indents with tabs" do
          expect( "foo\n\tbar".indent(2) ).to eql "\t\tfoo\n\t\t\tbar"
        end
      end

      context "string without indentation" do
        it "indents with space" do
          expect( "foo\nbar".indent(3) ).to eql "   foo\n   bar"
        end
      end

      context "string that only contain newlines (edge cases)" do
        it "doesn't indent at all" do
          ['', "\n", "\n" * 7].each do |str|
            expect( str.indent(8) ).to eql str
            expect( str.indent(1, "\t") ).to eql str
            expect( str.indent!(8) ).to be_nil
          end
        end
      end
    end

    context "with indent_str" do
      it "indents lines with the specified string" do
        expect( "foo\n  bar".indent(2, '.') ).to eql "..foo\n..  bar"
      end
    end

    context "with indent_empty_lines" do
      it "indents all lines including empty ones" do
        expect( "foo\n\nbar".indent(2, nil, true) ).to eql "  foo\n  \n  bar"
      end
    end
  end
end
