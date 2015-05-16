describe String do
  using Corefines::String[:snake_case, :snakecase]

  describe '#snake_case' do

    {
      'snakeCase'  => 'snake_case',
      'SnakeCase'  => 'snake_case',
      'SNAkeCASe'  => 'sn_ake_ca_se',
      'Snake2Case' => 'snake2_case',
      'snake2case' => 'snake2case'
    }
    .each do |str, expected|
      it "converts CamelCase to snake_case: #{str} => #{expected}" do
        expect( str.snake_case ).to eq expected
      end
    end

    it "converts white spaces to underscores" do
      ["Sssnake Case  Yay!", "Sssnake\tCase\t\tYay!"].each do |str|
        expect( str.snake_case ).to eq 'sssnake_case__yay!'
      end
    end

    it "converts hyphens to underscores" do
      expect( 'Sss-nake--case!'.snake_case ).to eq 'sss_nake__case!'
    end

    it "doesn't squeeze underscores" do
      expect( '__snake__case__'.snake_case ).to eq '__snake__case__'
    end

    it "doesn't modify the original string" do
      str = 'SnakeCase'
      origo = str.dup
      expect( str.snake_case ).to eq 'snake_case'
      expect( str ).to eq origo
    end
  end
end
