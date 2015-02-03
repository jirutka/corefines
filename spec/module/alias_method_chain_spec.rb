describe Module do
  using Corefines::Module::alias_method_chain

  describe '#alias_method_chain' do

    context "regular method" do

      subject :obj do
        Class.new {
          def say; 'say' end
          def say_with_accent; 'say_with_accent' end
          alias_method_chain :say, :accent
        }.new
      end

      it "defines method alias x_without_y -> x" do
        expect(obj.say_without_accent).to eq 'say'
      end

      it "defines method alias x -> x_with_y" do
        expect(obj.say).to eq 'say_with_accent'
      end
    end

    context "method with punctuation" do

      subject :obj do
        Class.new {
          def say!; 'say!' end
          def say_with_accent!; 'say_with_accent!' end
          alias_method_chain :say!, :accent
        }.new
      end

      it "defines method alias x_without_y! -> x!" do
        expect(obj.say_without_accent!).to eq 'say!'
      end

      it "defines method alias x! -> x_with_y!" do
        expect(obj.say!).to eq 'say_with_accent!'
      end
    end

    context "feature with punctuation" do

      subject :obj do
        Class.new {
          def say; 'say' end
          def say_with_accent?; 'say_with_accent?' end
          alias_method_chain :say, :accent?
        }.new
      end

      it "defines method alias x_without_y? -> x" do
        expect(obj.say_without_accent?).to eq 'say'
      end

      it "defines method alias x -> x_with_y?" do
        expect(obj.say).to eq 'say_with_accent?'
      end
    end


    [:public, :protected, :private].each do |visibility|
      it "preserves #{visibility} method visibility" do
        klass = Class.new.class_eval <<-CLASS
          def say; end
          def say_with_accent; end
          #{visibility} :say
          alias_method_chain :say, :accent
        CLASS
        expect(klass.send("#{visibility}_method_defined?", :say)).to be true
      end
    end
  end
end
