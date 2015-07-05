describe Enumerable do
  using Corefines::Enumerable::many?

  describe '#many?' do

    shared_examples :without_block do |enum, expected|
      context enum.class do
        it { expect( enum.many? ).to be expected }
      end
    end

    context "when empty" do
      [ [], Set.new, {} ].each do |enum|
        include_examples :without_block, enum, false
      end
    end

    context "when one element" do
      [ [42], Set.new([42]), {a: 42} ].each do |enum|
        include_examples :without_block, enum, false
      end
    end

    context "when two elements" do
      [ [1, 2], Set.new([1, 2]), {a: 1, b: 2} ].each do |enum|
        include_examples :without_block, enum, true
      end
    end

    context "when two nil elements" do
      [ [nil, nil], {a: nil, b: nil} ].each do |enum|
        include_examples :without_block, enum, true
      end
    end

    context "when more than two elements" do
      [ [1, 2, 3], Set.new([1, 2, 3]), {a: 1, b: 2, c: 3} ].each do |enum|
        include_examples :without_block, enum, true
      end
    end


    context "with block" do

      context "that yields true for one element" do
        context Array do
          it { expect( [1, 2].many? { |n| n > 1 } ).to eq false }
        end

        context Hash do
          it { expect( {a: 1, b: 2}.many? { |k, v| v > 1 } ).to eq false }
        end
      end

      context "that yield true for two elements" do
        context Array do
          it { expect( [1, 2].many? { |n| n > 0 } ).to eq true }
        end

        context Hash do
          it { expect( {a: 1, b: 2}.many? { |k, v| k.is_a?(Symbol) } ).to eq true }
        end
      end
    end
  end
end
