describe Object do
  using Corefines::Object::else

  describe '#else' do

    it "returns self without calling the block" do
      obj = 'yay'
      expect(obj.else { fail }).to eql obj
    end

    [ nil, false ].each do |val|
      context "called on #{val.nil? ? 'nil' : val}" do

        it "calls the block and returns result" do
          expect(val.else { 42 }).to eq 42
        end

        it "passes self to the block" do
          val.else { |x| expect(x).to eql val }
        end
      end
    end
  end
end
