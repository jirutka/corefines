describe String do
  using Corefines::String::to_b

  describe '#to_b' do

    ['true', 'yes', 'on', 't', 'y', '1', ' true ', 'YeS', '  1'].each do |str|
      context "given '#{str}'" do
        subject { str.to_b }
        it { is_expected.to be true }
      end
    end

    ['false', 'no', 'off', 'f', 'n', '0', ' FalsE ', 'xyz', ''].each do |str|
      context "given '#{str}'" do
        subject { str.to_b }
        it { is_expected.to be false }
      end
    end
  end
end
