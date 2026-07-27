# picodx

A minimal PicoRuby.wasm gem template — pure Ruby, no C extensions, distributed via npm.

## Usage

```html
<!DOCTYPE html>
<html>
  <head><meta charset="utf-8"></head>
  <body>
    <h1 id="greeting"></h1>
    <!-- Replace @0.1.0 with the published version -->
    <script type="text/ruby" src="https://cdn.jsdelivr.net/npm/picodx@0.1.0/lib/picodx.rb"></script>
    <script type="text/ruby">
      PicoDX::Greeter.new('greeting').greet('PicoRuby')
    </script>
    <script src="https://cdn.jsdelivr.net/npm/@picoruby/wasm-wasi@0.9.6/dist/init.iife.js"></script>
  </body>
</html>
```

## Development

```bash
npm run setup  # install dependencies

# Unit tests
bundle exec rspec spec/picodx/

# Serve examples locally (manual WASM verification)
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
