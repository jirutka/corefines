require 'corefines/support/fake_refinements'

describe Corefines::Support::FakeRefinements do

  before do
    rename_private_method ::Module, :refine, :__refine
    rename_private_method ::Module, :using, :__using

    # Doesn't work in rspec when included only in Module.
    Object.send(:include, described_class)

    F = create_fixture_modules
  end

  # Cleanup
  after do
    Object.send(:remove_const, :F)
    rename_private_method ::Module, :__refine, :refine
    rename_private_method ::Module, :__using, :using
  end


  describe '#refine' do

    it 'raises TypeError when argument is not a Class' do
      expect { Module.new { refine(:Foo) {} } }.to raise_error TypeError
    end

    it 'raises ArgumentError when no block given' do
      expect { Module.new { refine(F::Chip) } }.to raise_error ArgumentError
    end
  end


  describe '#using' do

    let(:chip) { F::Chip.new }
    let(:dale) { F::Dale.new }

    # Preconditions
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

  #
  # Helpers
  #

  def rename_private_method(klass, old_name, new_name)
    return unless klass.private_method_defined? old_name

    klass.send(:alias_method, new_name, old_name)
    klass.send(:remove_method, old_name)
  end

  def create_fixture_modules
    # Define dynamically to not pollute global context of other tests.
    Module.new.tap do |m|
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
