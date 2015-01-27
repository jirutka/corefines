describe String do
  using Corefines::String::unindent

  describe '#unindent' do

    context "single-line" do

      it "removes space indentation" do
        expect("  abc".unindent).to eq 'abc'
      end

      it "removes tab indentation" do
        expect("\tabc".unindent).to eq 'abc'
      end

      it "removes mixed space and tab indentation" do
        expect("\t\s\t\sabc".unindent).to eq 'abc'
      end
    end

    context "multi-line" do

      it "removes indentation" do
        expect(" abc\n abc".unindent).to eq "abc\nabc"
      end

      it "keeps relative indentation" do
        expect("  abc\n abc".unindent).to eq " abc\nabc"
      end

      it "ignores blank lines for indent calculation" do
        expect("\n\tabc\n\n\t\tabc\n".unindent).to eq "\nabc\n\n\tabc\n"
      end

      it "unindents more complex input" do
        input = <<-EOF
          module WishScanner

            def scan_for_a_wish
              wish = self.read.detect do |thought|
                thought.index('wish: ') == 0
              end

              wish.gsub('wish: ', '')
            end
          end
        EOF

        expected = <<-EOF
module WishScanner

  def scan_for_a_wish
    wish = self.read.detect do |thought|
      thought.index('wish: ') == 0
    end

    wish.gsub('wish: ', '')
  end
end
        EOF

        expect(input.unindent).to eq expected
      end
    end
  end
end
