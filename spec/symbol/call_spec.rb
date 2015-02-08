describe Symbol do
  using Corefines::Symbol::call

  describe '#call' do

    it "invokes method with one argument" do
      ary = [1, 2, 3]
      expect(ary.map(&:to_s.(2))).to eq ary.map { |n| n.to_s(2) }
    end

    it "invokes method with two arguments" do
      ary = %w[Chloe Drew Uma]
      expect(ary.map(&:gsub.('e', 'E'))).to eq ary.map { |s| s.gsub('e', 'E') }
    end
  end
end
