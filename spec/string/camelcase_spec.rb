describe String do
  using Corefines::String::camelcase

  describe '#camelcase' do

    it "doesn't modify the original string" do
      str = 'camel_case'
      origo = str.dup
      expect( str.camelcase ).to eq "camelCase"
      expect( str ).to eq origo
    end

    context "default" do

      it "capitalizes at underscore(s)" do
        expect( 'camel__case_4you!'.camelcase ).to eq 'camelCase4you!'
      end

      it "capitalizes at white space(s)" do
        expect( 'camel case  4 you!'.camelcase ).to eq 'camelCase4You!'
        expect( "camel\tcase\t\t4you!".camelcase ).to eq 'camelCase4you!'
      end
    end

    context "with string separator" do

      it "capitalizes at the separator" do
        expect( 'camel/case'.camelcase('/') ).to eq 'camelCase'
      end

      it "capitalizes at all of the given separators" do
        expect( 'camel/case;allons-y!'.camelcase('/', ';', '-') ).to eq 'camelCaseAllonsY!'
      end

      it "capitalizes at multiple occurrences of the separator" do
        expect( 'camel--case-here'.camelcase('-') ).to eq 'camelCaseHere'
        expect( '-Camel--case-here-'.camelcase('-') ).to eq 'CamelCaseHere-'
      end

      it "capitalizes at occurrences of the multichar separator" do
        expect( 'camel->case'.camelcase('->') ).to eq 'camelCase'
      end
    end

    context "with regexp separator" do
      it "capitalizes at matches of the regexp" do
        expect( 'camel22case'.camelcase(/[0-9]+/) ).to eq 'camelCase'
      end
    end

    context "with :lower" do
      it "capitalizes and converts the first letter to lower case" do
        expect( 'CAmeL Case'.camelcase(:lower) ).to eq 'cAmeLCase'
      end
    end

    context "with :upper" do
      it "capitalizes at default separators and converts the first letter to upper case" do
        expect( 'camel_case yay'.camelcase(:upper) ).to eq 'CamelCaseYay'
      end

      context "and separator" do
        it "capitalizes at the separator and converts the first letter to upper case" do
          expect( 'camel-case'.camelcase(:upper, '-') ).to eq 'CamelCase'
        end
      end
    end
  end
end
