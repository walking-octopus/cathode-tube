# CathodeTube
A native YouTube client for UT

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
