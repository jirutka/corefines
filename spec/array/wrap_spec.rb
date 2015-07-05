describe Array do
  using Corefines::Array::wrap

  describe '.wrap' do

    context "array" do
      it "returns the given array unchanged" do
        ary = ['foo', 'bar']
        expect( Array.wrap(ary) ).to be ary
      end
    end

    context "nil" do
      it "returns an empty array" do
        expect( Array.wrap(nil) ).to eq []
      end
    end

    context "an object" do
      it "returns it wrapped in an array" do
        o = Object.new
        expect( Array.wrap(o) ).to eq [o]
      end
    end

    context "string" do
      it "returns it wrapped in an array" do
        expect( Array.wrap("foo\nbar") ).to eq ["foo\nbar"]
      end
    end

    context "object with #to_ary" do

      it "returns result of #to_ary" do
        o = Class.new { def to_ary; ['foo', 'bar'] end }.new
        expect( Array.wrap(o) ).to eq o.to_ary
      end

      it "returns wrapped if #to_ary returns nil" do
        o = Class.new { def to_ary; nil end }.new
        expect( Array.wrap(o) ).to eq [o]
      end

      it "doesn't complain if #to_ary doesn't return an array" do
        o = Class.new { def to_ary; :not_an_array end }.new
        expect( Array.wrap(o) ).to eq o.to_ary
      end
    end
  end
end
