# coding: utf-8
using Corefines::Object::blank?

describe Object do
  describe '#blank?' do
    it { expect(Object.new.blank?).to be false }

    context "when object responds to #empty?" do
      it "returns true when #empty? is truthy" do
        cls = Class.new { define_method(:empty?) { 0 } }
        expect(cls.new.blank?).to be true
      end

      it "returns false when #empty? is falsy" do
        cls = Class.new { define_method(:empty?) { nil } }
        expect(cls.new.blank?).to be false
      end
    end
  end
end

describe NilClass do
  describe '#blank?' do
    it { expect(nil.blank?).to be true }
  end
end

describe FalseClass do
  describe '#blank?' do
    it { expect(false.blank?).to be true }
  end
end

describe TrueClass do
  describe '#blank?' do
    it { expect(true.blank?).to be false }
  end
end

describe Array do
  describe '#blank?' do
    it { expect([].blank?).to be true }
    it { expect([1].blank?).to be false }
  end
end

describe Hash do
  describe '#blank?' do
    it { expect({}.blank?).to be true }
    it { expect({x: 0}.blank?).to be false }
  end
end

describe Numeric do
  describe '#blank?' do
    [ 0, 1, 1.1 ].each do |val|
      it { expect(val.blank?).to be false }
    end
  end
end

describe String do
  describe '#blank?' do
    [ '', ' ', " \n\t \r ", '　', "\u00a0" ].each do |val|
      it { expect(val.blank?).to be true }
    end
    it { expect('x'.blank?).to be false }
  end
end
