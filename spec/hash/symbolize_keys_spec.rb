describe Hash do
  using Corefines::Hash::symbolize_keys

  subject(:mixed) { {'a' => 'foo', :b => 42, true => 66} }
  let(:symbolized) { {:a => 'foo', :b => 42, true => 66} }
  let!(:original) { mixed.dup }

  describe '#symbolize_keys' do
    it "returns a new hash with keys converted to symbols" do
      expect(mixed.symbolize_keys).to eq symbolized
      expect(mixed).to eql original
    end
  end

  describe '#symbolize_keys!' do
    it "converts keys to symbols" do
      expect(mixed.symbolize_keys!).to eq symbolized
      expect(mixed).to eq symbolized
    end
  end
end
