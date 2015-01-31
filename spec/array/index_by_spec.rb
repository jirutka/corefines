describe Array do
  using Corefines::Array::index_by

  describe '#index_by' do

    let(:input) { %w[alpha bee beta gamma] }
    let(:expected) { {a: 'alpha', b: 'beta', g: 'gamma'} }

    context "with block" do
      it "returns hash with the array's elements keyed be result of the block" do
        expect(input.index_by { |s| s[0].to_sym }).to eq expected
      end
    end

    context "without block" do
      it "returns enumerator that behaves the same as when block is given" do
        expect(input.index_by).to be_instance_of Enumerator
        expect(input.index_by.each { |x| x[0].to_sym }).to eq expected
      end
    end
  end
end
