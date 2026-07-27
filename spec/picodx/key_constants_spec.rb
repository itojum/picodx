RSpec.describe 'PicoDX key constants' do
  it 'maps arrow keys to KeyboardEvent.code strings' do
    expect(PicoDX::K_LEFT).to  eq('ArrowLeft')
    expect(PicoDX::K_RIGHT).to eq('ArrowRight')
    expect(PicoDX::K_UP).to    eq('ArrowUp')
    expect(PicoDX::K_DOWN).to  eq('ArrowDown')
  end

  it 'maps A-Z to KeyA-KeyZ' do
    expect(PicoDX::K_A).to eq('KeyA')
    expect(PicoDX::K_Z).to eq('KeyZ')
  end

  it 'maps common action keys' do
    expect(PicoDX::K_SPACE).to  eq('Space')
    expect(PicoDX::K_ESCAPE).to eq('Escape')
    expect(PicoDX::K_RETURN).to eq('Enter')
  end
end
