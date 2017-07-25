describe String do
  using Corefines::String::color

  describe '#color' do

    shared_examples :defaults do |opts|
      it "returns text with the default mode, foreground and background colors" do
        expect(text.color(opts)).to eq "\e[0;39;49m#{text}\e[0m"
      end
    end

    subject(:text) { "This is\nsome text" }

    context Symbol do
      it "returns text with the specified foreground color" do
        expect(text.color(:blue)).to eq "\e[0;34;49m#{text}\e[0m"
      end

      context "unknown color name" do
        include_examples :defaults, :foo
      end
    end

    context Integer do
      it "returns text with the specified foreground color" do
        expect(text.color(7)).to eq "\e[0;37;49m#{text}\e[0m"
      end
    end

    context Hash do

      context "empty" do
        include_examples :defaults, {}
      end

      context "with unknown mode and color names" do
        include_examples :defaults, {mode: :foo, text: :foo, background: :foo}
      end

      context "with valid options" do
        it "returns text with the specified mode" do
          [:bold, 1].each do |mode|
            expect(text.color(mode: mode)).to eq "\e[1;39;49m#{text}\e[0m"
          end
        end

        it "returns text with the specified foreground color" do
          [:red, 1].each do |color|
            expect(text.color(text: color)).to eq "\e[0;31;49m#{text}\e[0m"
          end
        end

        it "returns text with the specified background color" do
          [:green, 2].each do |color|
            expect(text.color(background: color)).to eq "\e[0;39;42m#{text}\e[0m"
          end
        end

        it "returns text with the specified mode, foreground and background colors" do
          expect(text.color(mode: :bold, text: :blue, background: :yellow)).to eq "\e[1;34;43m#{text}\e[0m"
          expect(text.color(mode: 1, text: 4, background: 3)).to eq "\e[1;34;43m#{text}\e[0m"
        end
      end
    end

    context "already colored text" do
      it "changes specified and preserves unspecified attributes" do
        expect("\e[1;34;42m#{text}\e[0m".color(text: :red)).to eq "\e[1;31;42m#{text}\e[0m"
      end

      it "doesn't change invalidly specified attributes" do
        expect("\e[1;34;42m#{text}\e[0m".color(text: :foo)).to eq "\e[1;34;42m#{text}\e[0m"
      end

      it "changes multiple escape sequences" do
        text = 'none' + 'red'.color(:red) + 'none' + 'blue'.color(:blue) + 'none'
        expected = "\e[0;39;42mnone\e[0m\e[0;31;42mred\e[0m\e[0;39;42mnone\e[0m\e[0;34;42mblue\e[0m\e[0;39;42mnone\e[0m"
        expect(text.color(background: :green)).to eq expected
      end
    end
  end
end
