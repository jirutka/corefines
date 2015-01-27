describe Hash do
  using Corefines::Hash::+

  describe '#+' do
    it 'merges hashes' do
      a = {a: 1, b: 2}
      b = {b: 3, c: 4}
      expect(a + b).to eq({a: 1, b: 3, c: 4})
    end
  end
end
