describe Array do
  using Corefines::Array::second

  describe '#second' do

    it "returns the second element" do
      expect(%w(a b c).second).to eq 'b'
    end
  end
end
