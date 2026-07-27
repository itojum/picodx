RSpec.describe PicoDX::Window do
  let(:ctx) do
    double('CanvasRenderingContext2D').tap do |d|
      allow(d).to receive(:[]=)
      allow(d).to receive(:save)
      allow(d).to receive(:restore)
      allow(d).to receive(:fillRect)
      allow(d).to receive(:strokeRect)
      allow(d).to receive(:fillText)
    end
  end

  let(:canvas) do
    double('HTMLCanvasElement').tap do |d|
      allow(d).to receive(:getContext).with('2d').and_return(ctx)
      allow(d).to receive(:[]).with(:width).and_return(double(to_i: 640))
      allow(d).to receive(:[]).with(:height).and_return(double(to_i: 480))
    end
  end

  before do
    js_document = double('document', getElementById: canvas)
    stub_const('JS', double('JS', document: js_document, eval: nil))
    allow(PicoDX::Input).to receive(:setup)
    described_class.init('game')
  end

  describe '.init' do
    it 'reads width and height from the canvas element' do
      expect(described_class.width).to eq(640)
      expect(described_class.height).to eq(480)
    end
  end

  describe '.draw' do
    it 'fills a rectangle using the image color and dimensions' do
      image = PicoDX::Image.new(32, 24, [255, 0, 0])
      expect(ctx).to receive(:[]=).with(:fillStyle, 'rgb(255,0,0)')
      expect(ctx).to receive(:fillRect).with(10, 20, 32, 24)
      described_class.draw(10, 20, image)
    end
  end

  describe '.draw_box' do
    it 'strokes a rectangle with the given color and coordinates' do
      expect(ctx).to receive(:[]=).with(:strokeStyle, 'rgb(0,128,255)')
      expect(ctx).to receive(:strokeRect).with(5, 10, 45, 40)
      described_class.draw_box(5, 10, 50, 50, [0, 128, 255])
    end
  end

  describe '.draw_box_fill' do
    it 'fills a rectangle with the given color and coordinates' do
      expect(ctx).to receive(:[]=).with(:fillStyle, 'rgb(0,255,0)')
      expect(ctx).to receive(:fillRect).with(10, 10, 100, 100)
      described_class.draw_box_fill(10, 10, 110, 110, [0, 255, 0])
    end

    it 'supports RGBA colors' do
      expect(ctx).to receive(:[]=).with(:fillStyle, 'rgba(255,0,0,1.0)')
      described_class.draw_box_fill(0, 0, 1, 1, [255, 0, 0, 255])
    end
  end

  describe '.draw_font' do
    it 'saves and restores canvas state around text rendering' do
      expect(ctx).to receive(:save).ordered
      expect(ctx).to receive(:[]=).with(:fillStyle, 'rgb(255,255,255)').ordered
      expect(ctx).to receive(:[]=).with(:font, '16px monospace').ordered
      expect(ctx).to receive(:[]=).with(:textBaseline, 'top').ordered
      expect(ctx).to receive(:fillText).with('hello', 10, 20).ordered
      expect(ctx).to receive(:restore).ordered
      described_class.draw_font(10, 20, 'hello', [255, 255, 255])
    end

    it 'uses the given font size' do
      allow(ctx).to receive(:save)
      allow(ctx).to receive(:restore)
      allow(ctx).to receive(:fillText)
      expect(ctx).to receive(:[]=).with(:font, '24px monospace')
      described_class.draw_font(0, 0, 'X', [0, 0, 0], 24)
    end
  end

  describe 'bgcolor rendering' do
    it 'clears the canvas with bgcolor on each tick' do
      described_class.bgcolor = [255, 0, 0]
      described_class.instance_variable_set(:@user_block, -> {})
      allow(PicoDX::Input).to receive(:_update)
      expect(ctx).to receive(:[]=).with(:fillStyle, 'rgb(255,0,0)').at_least(:once)
      expect(ctx).to receive(:fillRect).with(0, 0, 640, 480).at_least(:once)
      described_class.send(:_tick)
    end
  end
end
