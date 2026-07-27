RSpec.describe PicoDX::Image do
  it 'stores width, height, and color' do
    img = described_class.new(32, 24, [255, 0, 0])
    expect(img.width).to eq(32)
    expect(img.height).to eq(24)
    expect(img.color).to eq([255, 0, 0])
  end

  it 'defaults color to black' do
    img = described_class.new(8, 8)
    expect(img.color).to eq([0, 0, 0])
  end
end
