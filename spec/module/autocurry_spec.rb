describe Module do
  using Corefines::Module::autocurry

  describe '#autocurry' do

    subject(:obj) { klass.new }

    context "without arguments" do

      let!(:klass) do
        Class.new do
          class << self
            private
            def method_added(name)
              (@called ||= []) << name
            end
          end

          def alpha(x) x end

          autocurry
          def beta(x) x end
          private
          def gamma(x) x end
        end
      end

      it "curries all methods after autocurry call" do
        expect( obj.beta ).to be_a Proc
        expect( obj.send(:gamma) ).to be_a Proc
      end

      it "preserves method visibility" do
        expect( klass.public_method_defined? :beta ).to be true
        expect( klass.private_method_defined? :gamma ).to be true
      end

      it "does not autocurry methods before autocurry call" do
        expect { obj.alpha }.to raise_error ArgumentError
      end

      it "does not override existing #method_added" do
        expect( klass.instance_variable_get(:@called) ).to eq [:alpha, :beta, :gamma]
      end

      it "defines #method_added as private" do
        expect( klass.singleton_class.private_method_defined?(:method_added) ).to be true
      end
    end

    context "with a single argument" do

      let(:klass) do
        Class.new do
          def alpha(x) x end
          autocurry :alpha
          def beta(x) x end
          def gamma(x) x end
          protected :gamma
          autocurry :gamma
        end
      end

      it "curries the specified method" do
        expect( obj.alpha ).to be_a Proc
        expect( obj.send(:gamma) ).to be_a Proc
      end

      it "preserves method visibility" do
        expect( klass.public_method_defined? :alpha ).to be true
        expect( klass.protected_method_defined? :gamma ).to be true
      end

      it "does not autocurry other methods" do
        expect { obj.beta }.to raise_error ArgumentError
      end
    end

    context "with multiple arguments" do

      let(:klass) do
        Class.new do
          def alpha(x) x end
          def beta(x) x end
          autocurry :alpha, :beta
          def gamma(x) x end
        end
      end

      it "curries the specified methods" do
        expect( obj.alpha ).to be_a Proc
        expect( obj.beta ).to be_a Proc
      end

      it "does not autocurry other methods" do
        expect { obj.gamma }.to raise_error ArgumentError
      end
    end


    describe "currying behaviour" do

      let(:klass) do
        Class.new do
          autocurry
          def add(x, y, z)
            x + y + z
          end
        end
      end

      context "when all parameters are provided" do
        it "invokes method normally" do
          expect( obj.add(1, 2, 3) ).to eq 6
        end
      end

      context "when less than required parameters are given" do
        it "returns a curried Proc" do
          expect( obj.add ).to be_a Proc
          expect( obj.add(1) ).to be_a Proc
          expect( obj.add(1, 2) ).to be_a Proc
        end
      end

      context "when required parameters are provided successively" do
        it "invokes curried Proc after giving the last parameter" do
          expect( obj.add(1).(2).(3) ).to eq 6
          expect( obj.add(1).(2, 3) ).to eq 6
          expect( obj.add(1, 2).(3) ).to eq 6
        end
      end

      context "when too many args passed to curried Proc" do
        it { expect { obj.add(1, 2).(3, 4) }.to raise_error ArgumentError }
      end
    end
  end
end
