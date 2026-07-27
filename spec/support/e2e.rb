require 'playwright'

PICODX_RB = File.expand_path('../../lib/picodx.rb', __dir__)
raise "lib/picodx.rb が見つかりません。先に 'npm run build' を実行してください" unless File.exist?(PICODX_RB)
WASM_CDN   = 'https://cdn.jsdelivr.net/npm/@picoruby/wasm-wasi@4.0.2/dist/init.iife.js'

RSpec.shared_context 'browser', :e2e do
  around do |example|
    Playwright.create(playwright_cli_executable_path: './node_modules/.bin/playwright') do |pw|
      pw.chromium.launch(headless: true) do |browser|
        @page = browser.new_page
        @page.route('http://picodx.test/lib/picodx.rb', ->(route, _request) {
          route.fulfill(body: File.read(PICODX_RB), contentType: 'text/plain')
        })
        example.run
      end
    end
  end

  let(:page) { @page }

  def load_ruby(code)
    page.set_content(<<~HTML)
      <!DOCTYPE html>
      <html><body>
        <canvas id="game" width="640" height="480"></canvas>
        <script type="text/ruby" src="http://picodx.test/lib/picodx.rb"></script>
        <script type="text/ruby">#{code}</script>
        <script src="#{WASM_CDN}"></script>
      </body></html>
    HTML
  end
end
