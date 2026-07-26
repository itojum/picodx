# picoruby_wasm_template

A minimal PicoRuby.wasm gem template — pure Ruby, no C extensions, distributed via npm.

## Usage

```html
<!DOCTYPE html>
<html>
  <head><meta charset="utf-8"></head>
  <body>
    <h1 id="greeting"></h1>
    <!-- Replace @0.1.0 with the published version -->
    <script type="text/ruby" src="https://cdn.jsdelivr.net/npm/picoruby_wasm_template@0.1.0/lib/picoruby_wasm_template.rb"></script>
    <script type="text/ruby">
      PicorubyWasmTemplate::Greeter.new('greeting').greet('PicoRuby')
    </script>
    <script src="https://cdn.jsdelivr.net/npm/@picoruby/wasm-wasi@0.9.6/dist/init.iife.js"></script>
  </body>
</html>
```

## Development

```bash
bundle install

# Unit tests (standard Ruby + js gem stub)
bundle exec rspec spec/picodx_spec.rb

# E2E tests (Playwright, requires internet for WASM runtime)
bundle exec playwright install chromium
bundle exec rspec spec/e2e_spec.rb

# Serve examples locally
npm run serve  # http://localhost:3000/examples/index.html
```

## Publishing

```bash
npm login
npm publish --dry-run
npm publish
```

## License

MIT
