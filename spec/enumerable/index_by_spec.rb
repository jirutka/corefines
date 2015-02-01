describe Enumerable do
  using Corefines::Enumerable::index_by

  describe '#index_by' do

    let(:input) { %w[alpha bee beta gamma] }
    let(:expected) { {a: 'alpha', b: 'beta', g: 'gamma'} }

    it "returns hash with the array's elements keyed be result of the block" do
      expect(input.index_by { |s| s[0].to_sym }).to eq expected
    end
  end
end
