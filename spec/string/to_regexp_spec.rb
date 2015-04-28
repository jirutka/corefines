# coding: utf-8

describe String do
  using Corefines::String::to_regexp

  describe 'to_regexp' do

    context "with defaults" do
      {
        '/foo/'      => /foo/,
        '/foo/i'     => /foo/i,
        '/foo/m'     => /foo/m,
        '/foo/x'     => /foo/x,
        '/foo/imx'   => /foo/imx,
        '/foo.*(o)/' => /foo.*(o)/,
        '/česk[yý]/' => /česk[yý]/,
        '/foo\/bar/' => /foo\/bar/,
        '/foo'       => nil,
        '/foo/z'     => nil
      }
      .each do |str, expected|
        it "returns regexp '#{expected.inspect}' for string '#{str}'" do
          expect(str.to_regexp).to eql expected
        end
      end

      %w[n e s u nesu].each do |kcode|
        it "ignores encoding option: #{kcode}" do
          expect("/foo/#{kcode}".to_regexp).to eql /foo/
        end
      end
    end

    context "with literal" do
      {
        '/(foo)*/' => %r{/\(foo\)\*/},
        '^foo)'     => /\^foo\)/
      }
      .each do |str, expected|
        it "returns regexp '#{expected.inspect}' for string '#{str}" do
          expect(str.to_regexp(literal: true)).to eql expected
        end
      end
    end

    context "with detect" do
      {
        ''           => nil,
        'foo'        => /foo/,
        '(foo)*'     => /\(foo\)\*/,
        '/[a-z]'     => /\/\[a\-z\]/,
        '^.foo/x'    => /\^\.foo\/x/,
        '//'         => //,
        '/(foo)*/im' => /(foo)*/im
      }
      .each do |str, expected|
        it "returns regexp '#{expected.inspect}' for string '#{str}'" do
          expect(str.to_regexp(detect: true)).to eql expected
        end
      end
    end

    context "with ignore_case" do
      it { expect('/foo/'.to_regexp(ignore_case: true)).to eql /foo/i }
    end

    context "with multiline" do
      it { expect('/foo/'.to_regexp(multiline: true)).to eql /foo/m }
    end

    context "with extended" do
      it { expect('/foo/'.to_regexp(extended: true)).to eql /foo/x }
    end
  end
end
