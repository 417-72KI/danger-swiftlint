# [![Docker Hub](http://dockeri.co/image/41772ki/danger-swiftlint)](https://hub.docker.com/r/41772ki/danger-swiftlint)

Docker image for Danger-Swift using SwiftLint

# Usage Sample

## Local Docker

```sh
$ docker run -v `pwd`:`pwd` -w `pwd` 41772ki/danger-swiftlint local
```

## GitHub Actions

```yml
name: Danger
on:
  pull_request:
    paths:
      - '.swiftlint.yml'
      - '**/*.swift'
jobs:
  Danger:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - name: Danger
        uses: 417-72KI/danger-swiftlint@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Note for version
- v3: Swift 5.3
- v2: Swift 5.2
- v1: Swift 5.1
