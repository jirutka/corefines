describe Module do
  using Corefines::Module::alias_class_method

  describe '#alias_class_method' do

    subject :klass do
      Class.new do
        def self.salute
          'Meow!'
        end
      end
    end

    it "defines new class method that calls the old class method" do
      klass.alias_class_method :say_hello!, :salute

      expect(klass).to respond_to :say_hello!
      expect(klass.say_hello!).to eq klass.salute
    end
  end
end
