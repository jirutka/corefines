describe Object do
  using Corefines::Object::then_if

  describe '#then_if' do

    shared_examples 'conditions evaluates to true' do |*conditions|
      it "yields self to the block and returns that block's value" do
        expect('yay'.then_if(*conditions) { |x| x + '!' }).to eq 'yay!'
      end
    end

    shared_examples 'conditions evaluates to false' do |*conditions|
      it "returns self without calling the block" do
        obj = 'yay'
        expect(obj.then_if(*conditions) { fail 'block should not be called' }).to eql obj
      end
    end


    context "no conditions given" do

      context "and self evaluates to true" do
        it_behaves_like 'conditions evaluates to true'
      end

      context "and self evaluates to false" do
        [ false, nil ].each do |val|
          it "returns self without calling the block" do
            expect(val.then_if { fail 'block should not be called' }).to eql val
          end
        end
      end
    end

    [ :ascii_only?, [:start_with?, 'y'], ->(x) { x.start_with? 'y' },
      :ascii_only?.to_proc, true, 'foo'
    ].each do |condition|
      context "with #{condition.class} condition" do
        include_examples 'conditions evaluates to true', condition
      end
    end

    [ :empty?, [:start_with?, 'x'], ->(x) { x.start_with? 'x' },
      :empty?.to_proc, false, nil
    ].each do |condition|
      context "with #{condition.class} condition that evaluates to true" do
        include_examples 'conditions evaluates to false', condition
      end
    end

    context "with multiple conditions" do

      context "all evaluates to true" do
        conditions = [ true, [:start_with?, 'y'], :ascii_only? ]
        include_examples 'conditions evaluates to true', *conditions
      end

      context "one evaluates to false" do
        conditions = [ true, [:start_with?, 'y'], false, :ascii_only? ]
        include_examples 'conditions evaluates to false', *conditions
      end
    end
  end
end
