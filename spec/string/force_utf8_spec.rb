# coding: utf-8

describe String do
  using Corefines::String::force_utf8

  describe '#force_utf8!' do

    context "string encoded in ISO-8859-1" do
      subject(:str) { 'foo'.encode(Encoding::ISO_8859_1) }

      it "sets encoding to UTF-8" do
        expect( str.force_utf8!.encoding ).to eql Encoding::UTF_8
        expect( str.encoding ).to eql Encoding::UTF_8
      end
    end

    context "string with bad bytes" do
      {
        "\xE3llons-y!" => "�llons-y!",
        "Al\xE9ons-y!" => "Al�ons-y!",
        "Al\xE9ons-y\x80" => "Al�ons-y�"
      }
      .each do |input, expected|
        context input.inspect do

          subject(:str) { input.dup }  # defreeze!

          it "replaces bad bytes with the replacement char" do
            expect( str.force_utf8! ).to eq expected
            expect( str ).to eq expected
          end

          it "produces a valid UTF-8 string" do
            str.force_utf8!
            expect( str.valid_encoding? ).to be true
            expect( str.encoding ).to eql Encoding::UTF_8
          end
        end
      end

      it "collapses multiple consecutive bad bytes into one replacement" do
        str = "abc\u3042\xE3\x80"
        expect( str.force_utf8! ).to eq "abc\u3042�"
        expect( str ).to eq "abc\u3042�"
        expect( str.valid_encoding? ).to be true
      end
    end
  end


  # force_utf8 just duplicates the string and calls force_utf8!, so there's no
  # need to test it thoroughly.
  describe '#force_utf8' do

    it "replaces bad bytes with the replacement char" do
      expect( "Al\xE9ons-y\x80".force_utf8 ).to eq "Al�ons-y�"
    end

    it "returns a copy of the string and keeps original unaffected" do
      str = '\xE3llons-y!'.encode(Encoding::ISO_8859_1)
      copy = str.dup
      str.force_utf8

      expect( str ).to eql copy
      expect( str.encoding ).to eql Encoding::ISO_8859_1
    end
  end
end
