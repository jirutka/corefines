describe Object do
  using Corefines::Object::deep_dup

  describe '#deep_dup' do

    it "duplicates array and its values" do
      ary = ['foo', 'bar']
      dup = ary.deep_dup
      dup[1].prepend('x')

      expect(dup).to_not be ary
      expect(ary[1]).to eq 'bar'
      expect(dup[1]).to eq 'xbar'
    end

    it "duplicates values inside a nested array" do
      ary = ['foo', ['bar', 'baz']]
      dup = ary.deep_dup
      dup[1][0].prepend('x')

      expect(ary[1][0]).to eq 'bar'
      expect(dup[1][0]).to eq 'xbar'
    end

    it "duplicates a nested hash" do
      hash = {a: {b: 'b'}}
      dup = hash.deep_dup
      dup[:a][:c] = 'c'

      expect(hash[:a][:c]).to be_nil
      expect(dup[:a][:c]).to eq 'c'
    end

    it "duplicates an object" do
      obj = ::Object.new
      dup = obj.deep_dup
      dup.instance_variable_set(:@a, 1)

      expect(obj.instance_variable_defined? :@a).to be_falsy
      expect(dup.instance_variable_defined? :@a).to be_truthy
    end

    it "calls #deep_dup on nested object when it responds to it" do
      obj = Object.new.instance_eval do
        def deep_dup; 'foo' end
        self
      end
      ary = [1, obj]
      dup = ary.deep_dup

      expect(ary[1]).to eql obj
      expect(dup[1]).to eq 'foo'
    end

    it "doesn't raise error for non-duplicable object" do
      [nil, false, true, :foo, 1.0, method(:to_s)].each do |obj|
        expect { obj.deep_dup }.to_not raise_error
      end
    end
  end
end
