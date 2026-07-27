RSpec.describe PicoDX::Input do
  before do
    described_class.instance_variable_set(:@keys_down,   {})
    described_class.instance_variable_set(:@keys_prev,   {})
    described_class.instance_variable_set(:@keys_pushed, {})
    described_class.instance_variable_set(:@listening,   false)
  end

  describe '.setup' do
    let(:handlers)    { {} }
    let(:js_document) { double('document') }

    before do
      stub_const('JS', double('JS', document: js_document))
      allow(js_document).to receive(:addEventListener) do |event, &block|
        handlers[event] = block
      end
      described_class.setup
    end

    it 'registers keydown and keyup listeners' do
      expect(handlers.keys).to contain_exactly('keydown', 'keyup')
    end

    it 'marks a key as down when keydown fires' do
      code = double(to_s: 'ArrowLeft')
      event = double.tap { |e| allow(e).to receive(:[]).with(:code).and_return(code) }
      handlers['keydown'].call(event)
      expect(described_class.key_down?('ArrowLeft')).to be true
    end

    it 'clears a key when keyup fires' do
      described_class.instance_variable_set(:@keys_down, { 'ArrowLeft' => true })
      code = double(to_s: 'ArrowLeft')
      event = double.tap { |e| allow(e).to receive(:[]).with(:code).and_return(code) }
      handlers['keyup'].call(event)
      expect(described_class.key_down?('ArrowLeft')).to be false
    end

    it 'does not re-register listeners on second call' do
      expect(js_document).not_to receive(:addEventListener)
      described_class.setup
    end
  end

  describe '.key_down?' do
    it 'returns true while the key is held' do
      described_class.instance_variable_set(:@keys_down, { 'ArrowLeft' => true })
      expect(described_class.key_down?('ArrowLeft')).to be true
    end

    it 'returns false when the key is not held' do
      expect(described_class.key_down?('ArrowLeft')).to be false
    end
  end

  describe '.key_push?' do
    it 'returns true on the frame a key is first pressed' do
      described_class.instance_variable_set(:@keys_down, { 'Space' => true })
      described_class._update
      expect(described_class.key_push?('Space')).to be true
    end

    it 'returns false on subsequent frames while the key remains held' do
      described_class.instance_variable_set(:@keys_down, { 'Space' => true })
      described_class._update
      described_class._update
      expect(described_class.key_push?('Space')).to be false
    end

    it 'returns false when the key has not been pressed' do
      described_class._update
      expect(described_class.key_push?('Space')).to be false
    end
  end

  describe '._update' do
    it 'resets pushed keys each frame' do
      described_class.instance_variable_set(:@keys_pushed, { 'ArrowRight' => true })
      described_class._update
      expect(described_class.key_push?('ArrowRight')).to be false
    end

    it 'tracks prev state so held keys are not re-pushed' do
      described_class.instance_variable_set(:@keys_down, { 'Enter' => true })
      described_class._update
      described_class._update
      expect(described_class.key_push?('Enter')).to be false
      expect(described_class.key_down?('Enter')).to be true
    end
  end
end
