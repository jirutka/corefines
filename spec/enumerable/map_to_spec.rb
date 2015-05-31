require 'pathname'

describe Enumerable do
  using Corefines::Enumerable::map_to

  describe '#map_to' do

    context Array do
      it "creates instance of the klass for every element and collects the result" do
        ary = ['/tmp', '/var/tmp']
        expect( ary.map_to(Pathname) ).to eq ary.map { |e| Pathname.new(e) }
      end
    end
  end
end
