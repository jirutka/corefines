describe Proc do
  using Corefines::Proc::>>

  describe '>>' do
    identity = ->(x) { x }
    negate = ->(n) { -n }
    plus1 = ->(n) { n + 1 }
    pow2 = ->(n) { n ** 2 }
    pow = ->(e, n) { n ** e }

    it "returns a Proc" do
      expect( identity >> plus1 ).to be_a Proc
    end

    it "pipelines result of this proc to the given lambda" do
      expect( (negate >> plus1).(5) ).to eq -4
      expect( (negate >> plus1 >> pow2).(5) ).to eq 16
    end

    context "with curryied lambda" do
      it "pipelines result of this proc to the given lambda" do
        expect( (plus1 >> pow.curry.(2)).(3) ).to eq 16
      end
    end

    context "with lambda that accepts *args" do
      it "passes single argument to the given lambda" do
        head = ->(*args) { args.first }
        expect( (identity >> head).([2, 4, 8]) ).to eq [2, 4, 8]
      end
    end
  end
end
