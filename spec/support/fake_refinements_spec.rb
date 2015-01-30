describe Corefines::Support::FakeRefinements do

  before :all do
    if Module.private_method_defined? :refine
      Module.send(:alias_method, :_old_refine, :refine)
    end

    [Object, Module].each do |klass|
      next unless klass.private_method_defined? :using
      klass.send(:alias_method, :_old_using, :using)
    end

    Corefines::Support::FakeRefinements.define_using(Object)
    Corefines::Support::FakeRefinements.define_refine(Module)
  end

  after :all do
    [Object, Module].each do |klass|
      next unless klass.private_method_defined? :_old_using
      klass.send(:alias_method, :using, :_old_using)
    end

    if Module.private_method_defined? :_old_refine
      Module.send(:alias_method, :refine, :_old_refine)
    end
  end

  before(:each) { F = create_fixture_modules }
  after(:each) { Object.send(:remove_const, :F) }

  let(:chip) { F::Chip.new }
  let(:dale) { F::Dale.new }


  describe 'Module#refine' do

    it "raises TypeError when argument is not a Class" do
      expect { Module.new { refine(:Foo) {} } }.to raise_error TypeError
    end

    it "raises ArgumentError when no block given" do
      expect { Module.new { refine(F::Chip) } }.to raise_error ArgumentError
    end
  end


  describe 'Object#using' do

    # Precondition checks
    before do
      expect(chip).to_not respond_to :run, :climb, :salute
      expect(dale).to_not respond_to :walk
    end

    context "module with no refines" do
      it { expect { using F }.to raise_error ArgumentError }
    end

    context "module with refines" do

      it "evals refinements defined in the module" do
        using F::Refs::A
        expect(chip).to respond_to :run, :climb
        expect(dale).to respond_to :walk
        expect(chip).to_not respond_to :salute
      end

      it "evals refinement only once" do
        expect(F::Dale).to receive(:class_eval).exactly(1).times
        2.times { using F::Refs::A }
      end
    end

    context "module that includes AliasSubmodules" do

      before do
        F::Refs.send(:include, Corefines::Support::AliasSubmodules)
      end

      it "evals refinements from submodules recursively" do
        using F::Refs
        expect(chip).to respond_to :run, :climb, :salute
        expect(dale).to respond_to :walk
      end

      it "doesn't eval refinements from submodules that have already been evaluated" do
        using F::Refs::A

        expect(F::Dale).to_not receive(:class_eval)
        expect(F::Chip).to receive(:class_eval).exactly(1).times
        using F::Refs
      end
    end
  end


  def create_fixture_modules
    # Define dynamically to not pollute global context of other tests.
    ::Module.new.tap do |m|
      m.class_eval <<-CODE
        class Chip; end
        class Dale; end

        module Refs
          module A
            refine Chip do
              def run; end
            end
            refine Chip do
              def climb; end
            end
            refine Dale do
              def walk; end
            end
          end

          module B
            refine Chip do
              def salute; end
            end
          end
        end
      CODE
    end
  end
end
