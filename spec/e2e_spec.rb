require 'playwright'
require 'socket'

ROOT = File.expand_path('..', __dir__)
PORT = 3001

RSpec.describe 'PicorubyWasmTemplate', :e2e do
  before(:all) do
    @server_pid = spawn("npx serve #{ROOT} -p #{PORT}", out: File::NULL, err: File::NULL)
    30.times do
      TCPSocket.new('localhost', PORT).close
      break
    rescue Errno::ECONNREFUSED
      sleep 0.5
    end
  end

  after(:all) do
    Process.kill('TERM', @server_pid) rescue nil
    Process.wait(@server_pid) rescue nil
  end

  around do |example|
    Playwright.create(playwright_cli_executable_path: './node_modules/.bin/playwright') do |pw|
      pw.chromium.launch(headless: true) do |browser|
        @page = browser.new_page
        example.run
      end
    end
  end

  let(:page) { @page }

  it 'displays "Hello, PicoRuby!" in the greeting element' do
    page.goto("http://localhost:#{PORT}/examples/index.html")
    page.wait_for_function(
      "() => document.getElementById('greeting').innerText === 'Hello, PicoRuby!'",
      timeout: 15_000
    )
    expect(page.inner_text('#greeting')).to eq('Hello, PicoRuby!')
  end
end
