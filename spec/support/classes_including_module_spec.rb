require 'corefines/support/classes_including_module'
require 'forwardable'

describe Corefines::Support do

  describe '.classes_including_module' do
    extend Forwardable

    def_delegator :described_class, :classes_including_module

    before :context do
      ModuleX, ModuleY = Module.new, Module.new
      ClassA, ClassB = Class.new, Class.new(Array)
      [ClassA, ClassB].each { |m| m.send(:include, ModuleX) }
    end

    after :context do
      [:ModuleX, :ModuleY, :ClassA, :ClassB].each do |name|
        Object.send(:remove_const, name)
      end
    end

    it "yields classes that includes the module" do
      actual = []
      classes_including_module(ModuleX) { |c| actual << c }
      expect(actual).to contain_exactly ClassA, ClassB
    end

    it "yields nothing for module that isn't included anywhere" do
      actual = []
      classes_including_module(ModuleY) { |c| actual << c }
      expect(actual).to be_empty
    end
  end
end
