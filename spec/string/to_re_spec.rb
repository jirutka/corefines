# coding: utf-8

describe String do
  using Corefines::String::to_re

  describe 'to_re' do

    context "with defaults" do
      {
        '/foo/'      => /foo/,
        '/foo/i'     => /foo/i,
        '/foo/m'     => /foo/m,
        '/foo/x'     => /foo/x,
        '/foo/imx'   => /foo/imx,
        '/foo.*(o)/' => /foo.*(o)/,
        '/česk[yý]/' => /česk[yý]/,
        '/foo\/bar/' => %r{foo/bar},
        '/foo'       => nil,
        '/foo/z'     => nil
      }
      .each do |str, expected|
        it "returns regexp '#{expected.inspect}' for string '#{str}'" do
          expect(str.to_re).to eql expected
        end
      end

      %w[n e s u nesu].each do |kcode|
        it "ignores encoding option: #{kcode}" do
          expect("/foo/#{kcode}".to_re).to eql /foo/
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
          expect(str.to_re(literal: true)).to eql expected
        end
      end
    end

    context "with detect" do
      {
        ''           => nil,
        'foo'        => /foo/,
        '(foo)*'     => /\(foo\)\*/,
        '/[a-z]'     => %r{/\[a\-z\]},
        '^.foo/x'    => %r{\^\.foo/x},
        '//'         => //,
        '/(foo)*/im' => /(foo)*/im
      }
      .each do |str, expected|
        it "returns regexp '#{expected.inspect}' for string '#{str}'" do
          expect(str.to_re(detect: true)).to eql expected
        end
      end
    end

    context "with ignore_case" do
      it { expect('/foo/'.to_re(ignore_case: true)).to eql /foo/i }
    end

    context "with multiline" do
      it { expect('/foo/'.to_re(multiline: true)).to eql /foo/m }
    end

    context "with extended" do
      it { expect('/foo/'.to_re(extended: true)).to eql /foo/x }
    end
  end
end
