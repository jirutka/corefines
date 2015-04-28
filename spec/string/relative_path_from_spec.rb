describe String do
  using Corefines::String::relative_path_from

  describe '#relative_path_from' do

    [
      [ '/home/flynn/tron', '/home',            'flynn/tron' ],
      [ '/home',            '/home/flynn/tron', '../..'      ],
      [ 'home/flynn/tron',  'home',             'flynn/tron' ],
      [ '../bin/run',       '.',                '../bin/run' ],
      [ '/usr/bin/../lib',  '/',                'usr/lib'    ]
    ]
    .each do |path, base, expected|
      it "returns '#{expected}' for path '#{path}' and base '#{base}'" do
        expect(path.relative_path_from(base)).to eql expected
      end
    end

    context "mismatched relative and absolute path" do
      {
        '/home/flynn' => 'home',
        'home/flynn'  => '/home'
      }
      .each do |path, base|
        it { expect { path.relative_path_from(base) }.to raise_error ArgumentError }
      end
    end
  end
end
