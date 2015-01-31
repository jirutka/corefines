describe Object do
  using Corefines::Object::instance_values

  describe '#instance_values' do
    let :obj do
      Object.new.tap do |o|
        o.instance_variable_set(:@foo, 'first')
        o.instance_variable_set(:@bar, 'second')
      end
    end

    it "returns hash that maps instance variables to their values" do
      expect(obj.instance_values).to eq({foo: 'first', bar: 'second'})
    end

    context "no instance variables" do
      it "returns an empty array" do
        expect(''.instance_values).to be_empty
      end
    end
  end
end
