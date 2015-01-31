# coding: utf-8
using Corefines::Object::blank?

describe Object do
  let(:obj) { Object.new }

  let :obj_empty do
    Class.new { define_method(:empty?) { 0 } }.new
  end

  let :obj_not_empty do
    Class.new { define_method(:empty?) { nil } }.new
  end

  describe '#blank?' do
    it { expect(obj.blank?).to be false }

    context "when object responds to #empty?" do
      it "returns true when #empty? is truthy" do
        expect(obj_empty.blank?).to be true
      end

      it "returns false when #empty? is falsy" do
        expect(obj_not_empty.blank?).to be false
      end
    end
  end

  describe '#presence' do
    it { expect(obj.presence).to be obj }

    context "when object responds to #empty?" do
      it "returns nil when #empty? is truthy" do
        expect(obj_empty.presence).to be nil
      end

      it "returns caller when #empty? is falsy" do
        expect(obj_not_empty.presence).to be obj_not_empty
      end
    end
  end
end

describe NilClass do
  describe '#blank?' do
    it { expect(nil.blank?).to be true }
  end

  describe '#presence' do
    it { expect(nil.presence).to be_nil }
  end
end

describe FalseClass do
  describe '#blank?' do
    it { expect(false.blank?).to be true }
  end

  describe '#presence' do
    it { expect(false.presence).to be_nil }
  end
end

describe TrueClass do
  describe '#blank?' do
    it { expect(true.blank?).to be false }
  end

  describe '#presence' do
    it { expect(true.presence).to be true }
  end
end

describe Array do
  describe '#blank?' do
    it { expect([].blank?).to be true }
    it { expect([1].blank?).to be false }
  end

  describe '#presence' do
    it { expect([].presence).to be_nil }
    it { expect([1].presence).to eq [1] }
  end
end

describe Hash do
  describe '#blank?' do
    it { expect({}.blank?).to be true }
    it { expect({x: 0}.blank?).to be false }
  end

  describe '#presence' do
    it { expect({}.presence).to be_nil }
    it { expect({x: 0}.presence).to eq({x: 0}) }
  end
end

describe Numeric do
  [ 0, 1, 1.1 ].each do |val|
    describe '#blank?' do
      it { expect(val.blank?).to be false }
    end

    describe '#presence' do
      it { expect(val.presence).to be val }
    end
  end
end

describe String do
  [ '', ' ', " \n\t \r ", '　', "\u00a0" ].each do |val|
    describe '#blank?' do
      it { expect(val.blank?).to be true }
    end

    describe '#presence' do
      it { expect(val.presence).to be_nil }
    end
  end

  describe '#blank?' do
    it { expect('x'.blank?).to be false }
  end

  describe '#presence' do
    it { expect('x'.presence).to eq 'x' }
  end
end
