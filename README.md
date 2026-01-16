# flymake-jsonlint

Flymake backend for JSON files using jsonlint.

## Description

flymake-jsonlint is an Emacs package that integrates the jsonlint JSON
linter with Emacs's built-in Flymake syntax checking framework. It enables
real-time syntax validation of JSON files within the editor.

## Requirements

You need to have `jsonlint` installed. Install it via npm:

```bash
npm install jsonlint -g
```

## Installation

```elisp
(use-package flymake-jsonlint
  ;; Load from a local copy
  :load-path "/path/to/flymake-jsonlint.el"
  ;; ... or clone from GitHub
  ;; :vc (:url "https://github.com/sonofjon/flymake-jsonlint.el"
  ;;          :rev :newest)
  :hook ((json-ts-mode js-json-mode) . flymake-jsonlint-load))
```

## Usage

### With Eglot

To use flymake-jsonlint together with Eglot, hook into `eglot-managed-mode`
instead of the JSON mode hooks:

```elisp
(use-package flymake-jsonlint
  :load-path "/path/to/flymake-jsonlint.el"
  :hook (eglot-managed-mode . flymake-jsonlint-load))
```

This allows both jsonlint (for syntax checking) and the JSON language server
(for schema validation) to run together in the same buffer.

## Customization

### `flymake-jsonlint-program`

Path to the jsonlint executable. Defaults to `"jsonlint"`.

```elisp
(setq flymake-jsonlint-program "/path/to/jsonlint")
```

## Alternatives

Several other Flymake backends exist for JSON validation:

- [**flymake-json**](https://github.com/purcell/flymake-json) (MELPA) - Uses
  jsonlint via the flymake-easy library. Compatible with older Flymake
  implementations (pre-Emacs 26).

- [**flymake-jsonlint**](https://codeberg.org/shaohme/flymake-jsonlint)
  (Codeberg) - Uses Python's json.tool module for validation.

- [**json-simple-flymake**](https://github.com/mokrates/json-simple-flymake)
  (GitHub) - Uses Emacs's built-in json-parse-buffer function. No external
  dependencies, but reports only one error at a time.
