# Bundling a game split into files

PicoRuby.wasm starts with an empty virtual file system, so `require './class/player.rb'` raises `LoadError` in the browser. `picodx bundle` resolves those requires before the game reaches the browser: it starts from an entry file, follows its `require` / `require_relative` statements and writes one Ruby script with every required file inlined where it was required.

```bash
npm install --save-dev picodx
npx picodx bundle main.rb -o game.bundle.rb
```

```html
<script type="text/ruby" src="https://cdn.jsdelivr.net/npm/picodx@latest/lib/picodx.rb"></script>
<script type="text/ruby" src="game.bundle.rb"></script>
<script src="https://cdn.jsdelivr.net/npm/@picoruby/wasm-wasi@latest/dist/init.iife.js"></script>
```

The game's own `require` lines stay as they are, so the same source still runs on DXRuby. The command needs Ruby 3.3 or later (it parses the files with Prism).

## How requires are resolved

| Written as | Resolved against |
|------------|------------------|
| `require_relative 'x'` | the directory of the file that contains it |
| `require './x'`, `require '../x'` | the root: the entry file's directory, or `--root DIR` (DXRuby games are run from their own folder) |
| `require 'x'` | the load paths: the root, or each `-I DIR` |
| `require '/abs/x'` | as written |

- `.rb` is added when it is missing, and `\` is read as `/`.
- Each file is inlined once, at its first require; later requires of the same file are removed. A circular require is skipped with a warning.
- `require 'x'` that is not found in the load paths is left in the bundle (once) and runs in the browser. This is how PicoRuby's built-in libraries such as `'js'` are loaded.
- `require 'dxruby'` is always removed, since PicoDX takes its place. Remove others with `--ignore NAME`, for example a library PicoRuby does not have, or a file that only makes sense on the desktop:

  ```bash
  npx picodx bundle main.rb -o game.bundle.rb --ignore set --ignore ./ranking.rb
  ```

- A local file (`./x`, `../x`, `require_relative`) that does not exist stops the build with an error that names the file. A syntax error in any file also stops the build, with its file and line.

## Limitations

- **Only top-level requires are bundled.** A require inside a method, block or `if` may run never or many times, so it is left as it is and reported as a warning; in the browser it fails unless it names a built-in library.
- **Inlined files share one scope.** In Ruby each required file has its own top-level local variables; in the bundle they are all in one script. A local variable with the same name in two files refers to the same variable.
- **`__FILE__`, `__dir__` and line numbers in error messages** refer to the bundle, not the original files. Each inlined file starts with a `# --- path ---` comment to help find the original line.
- **`__END__` / `DATA`:** the data after `__END__` is dropped, with a warning.

## Why not require at runtime?

Making `require` work in the browser looks possible: fetch the file, write it to PicoRuby.wasm's virtual file system (`window.picorubyModule.FS`) and `load` it. `load` does read that file system, but when a file being loaded awaits a Promise that is not yet resolved (`Image.load`, `Sound.new`, `fetch`, a timer), the rest of that file is skipped without an error and `load` returns as if it had finished. Games commonly load images at the top of a file (`$tiles = Image.load_tiles(...)`), so a runtime require would silently leave those files half-run. Resolving requires at build time keeps every file in one task, where `await` works.
