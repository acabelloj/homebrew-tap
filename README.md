# acabelloj/homebrew-tap

Homebrew tap for my personal macOS apps.

## Available casks

| Cask | Description |
|------|-------------|
| [`desktop-pet`](Casks/desktop-pet.rb) | A pixel-art desktop companion that lives on your screen ([releases](https://github.com/acabelloj/desktop-pet-releases)) |

## Install

You need [Homebrew](https://brew.sh) installed first.

### Quick install

Install any cask from this tap in one step — Homebrew adds the tap automatically:

```sh
brew install acabelloj/tap/<cask>
```

For example, to install `desktop-pet`:

```sh
brew install acabelloj/tap/desktop-pet
```

`acabelloj/tap` is shorthand for this repository (`acabelloj/homebrew-tap`).

### Tap first, then install

If you'd rather add the tap once and install by short name afterwards:

```sh
brew tap acabelloj/tap
brew install desktop-pet
```

### In a Brewfile

```ruby
tap "acabelloj/tap"
cask "desktop-pet"
```

Then run `brew bundle`.

### If you're asked to trust the tap

Some casks run an install step (a `postflight` block). If you have
`HOMEBREW_REQUIRE_TAP_TRUST` set, Homebrew won't load them until you trust the
tap. Run this once, then install again:

```sh
brew trust acabelloj/tap
```

## Upgrade & uninstall

```sh
brew upgrade --cask desktop-pet          # update to the latest release
brew uninstall --cask desktop-pet        # remove the app
brew uninstall --zap --cask desktop-pet  # also remove its leftover files
```

Replace `desktop-pet` with any other cask name from the table above.

## Documentation

`brew help`, `man brew`, or [Homebrew's documentation](https://docs.brew.sh).
