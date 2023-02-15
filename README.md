<img height="128" src="https://raw.githubusercontent.com/walking-octopus/cathode-tube/main/assets/logo.png" align="left"/>

# CathodeTube
A fast, convergent, and native custom YouTube client for Ubuntu Touch.

_____________________________________________

## Development status

The core features, like search, playback, video info, playlists, or feeds, work fine.
Still, quite a few things still need to be implemented, some edge cases are not handled well, hardware acceleration is missing, and the design may need a bit of work. I'd say it's (almost) good enough to be a daily-driver.

Alse, the app's backend is also a little outdated, using the unsupported YouTube.js v1. I'm currently rewriting it for YouTube.js v2 (see issue #5), but in the meantime, some hacks had to be used to keep it together. The new version would make the app speedier, more maintainable, and would unblock new many features.

## Testing

If you're a casual user who just wants to help out testing the app, just download the [latest build from GitHub Actions](https://github.com/walking-octopus/cathode-tube/actions). Simply select a `.click` file for your architecture from artifacts and open it with OpenStore. Report any issues, suggestions, or design proposels in [Issues](https://github.com/walking-octopus/cathode-tube/issues). If you want to see this app in your language, feel free to help out with translation! (may require localization updates due to the UI still being subject to change).

## Building

### Dependencies
- Docker
- Android tools (for adb)
- NodeJS
- Python3 / pip3
- Clickable (get it from [here](https://clickable-ut.dev/en/latest/index.html))

Use Clickable to build and package CathodeTube as a Click package ready to be installed on Ubuntu Touch

### Build instructions
Make sure you clone the project with
`git clone https://github.com/walking-octopus/cathode-tube`.

Install development NPM dependencies with
```
$  clickable script fetch-dev
```

The project uses bundled NodeJS, so you'd have to download it for each architecture you'll build for.
```
$  clickable build --libs nodejs --arch armhf;
$  clickable build --libs nodejs --arch amd64;
```
where `arch` is one of: `amd64`, `arm64` or `armhf`.


_______________________

### Patching YouTube.js v1
Due to YouTube.js v1 that this project currently uses being no longer supported, some things are slowly starting to break with YouTube updates. I am working on migrating to v2, but in the meantime, you could apply a tiny patch to avoid crashing.
The most problematic of changes was the new like button, which caused `getDetails()` to crash the app. The workaround is to ignore the like button and use slightly less up-to-date stats from ReturnYouTubeDislike.

To apply the patch, run this after fetching `node_modules`:
```
$  clickable script patch
```
_________________________


To test the build on your workstation:
```
$  clickable desktop
```

To prune development dependencies:
```
$  clickable script fetch-production
```

To build for your phone:
```
$  clickable --arch armhf
```
where `arch` is one of: `amd64`, `arm64` or `armhf`.

For more information on the several options see the Clickable [documentation](https://clickable-ut.dev/en/latest/index.html)

## License
The project is licensed under the [GPL-3.0](https://opensource.org/licenses/GPL-3.0).
