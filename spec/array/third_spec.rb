describe Array do
  using Corefines::Array::third

  describe '#third' do

    it "returns the third element" do
      expect(%w(a b c).third).to eq 'c'
    end
  end
end
