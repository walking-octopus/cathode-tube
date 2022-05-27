# CathodeTube
A native YouTube client for UT

## Building

### Dependencies
- Docker
- Android tools (for adb)
- Python3 / pip3
- Clickable (get it from [here](https://clickable-ut.dev/en/latest/index.html))

Use Clickable to build and package CathodeTube as a Click package ready to be installed on Ubuntu Touch

### Build instructions
Make sure you clone the project with
`git clone https://github.com/walking-octopus/cathode-tube`.

Install development NPM dependencies with
`cd yt-ws; npm i`

The project uses bundled NodeJS, so you'd have to redownload each time you build for a different architecture.

To test the build on your workstation:
```
$  clickable build --libs nodejs; clickable desktop
```

To build for a production:
```
$  clickable script fetch; clickable build --libs nodejs --arch armhf; clickable --arch armhf
```
where `arch` is one of: `amd64`, `arm64` or `armhf`.

For more information on the several options see the Clickable [documentation](https://clickable-ut.dev/en/latest/index.html)

## License
The project is licensed under the [GPL-3.0](https://opensource.org/licenses/GPL-3.0).