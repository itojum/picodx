RSpec.describe PicoDX::Greeter do
  describe '#greet' do
    it 'sets innerText on the specified element' do
      described_class.new('greeting').greet('PicoRuby')
      expect(JS.document.getElementById('greeting').innerText).to eq('Hello, PicoRuby!')
    end

    it 'includes the given name in the message' do
      described_class.new('msg').greet('World')
      expect(JS.document.getElementById('msg').innerText).to eq('Hello, World!')
    end
  end
end
