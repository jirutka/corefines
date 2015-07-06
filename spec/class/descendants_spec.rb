describe Class do
  using Corefines::Class::descendants

  describe '#descendants' do

    a = Class.new
    b0 = Class.new(a)
    b1 = Class.new(a)
    c0 = Class.new(b0)

    context 'when class without subclasses' do
      it { expect( c0.descendants ).to be_empty }
    end

    context 'when class with 2 generations of descendants' do
      it 'returns all descendants of the class' do
        expect( a.descendants ).to match_array [b0, b1, c0]
      end
    end

  end
end
