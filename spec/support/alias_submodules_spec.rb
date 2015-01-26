describe Corefines::Support::AliasSubmodules do

  describe '#included' do

    before :context do
      # Define dynamically to not pollute global context of other tests.
      ModuleX = Module.new.tap do |m|
        m.class_eval <<-CODE
          Something = 66
          module Indent end
          module StripHeredoc end
          include Corefines::Support::AliasSubmodules
        CODE
      end
    end

    after :context do
      Object.send(:remove_const, :ModuleX)
    end

    subject(:target) { ModuleX }

    it "defines method :* that returns itself" do
      expect(ModuleX::*).to eql ModuleX
    end

    it 'defines method-named "alias" for each submodule' do
      expect(ModuleX.indent).to eql ModuleX::Indent
      expect(ModuleX::strip_heredoc).to eql ModuleX::StripHeredoc
    end

    it "ignores constants that are not modules" do
      is_expected.to_not respond_to :something
    end

    it "includes all submodules into the target" do
      is_expected.to include ModuleX::Indent, ModuleX::StripHeredoc
    end
  end


  describe '#underscore' do

    def underscore(str)
      described_class.send(:underscore, str)
    end

    it "string without any uppercase returns untouched" do
      str = 'allonsy!'
      expect(underscore str).to eql str
    end

    {
      'Unindent' => 'unindent',
      'StripHeredoc' => 'strip_heredoc',
      'ToJSON' => 'to_json'
    }.each do |input, expected|
      it "converts '#{input}' to '#{expected}'" do
        input_clone = input.dup
        expect(underscore input).to eq expected
        expect(input).to eql input_clone
      end

      it "converts :#{input} to '#{expected}'" do
        expect(underscore input.to_sym).to eq expected
      end
    end
  end
end
