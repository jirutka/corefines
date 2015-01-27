describe Symbol do
  using Corefines::Symbol::~

  describe '#~' do
    it "converts Symbol to Proc" do
      proc = ~:upcase
      expect(proc).to be_instance_of Proc
      expect(proc.call('foo')).to eq 'FOO'
    end
  end
end
