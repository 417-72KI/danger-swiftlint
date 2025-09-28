# [![Docker Hub](https://dockeri.co/image/41772ki/danger-swiftlint)](https://hub.docker.com/r/41772ki/danger-swiftlint)

Docker image for [Danger-Swift](https://github.com/danger/swift) using [SwiftLint](https://github.com/realm/SwiftLint)

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
      - uses: actions/checkout@v4
      - name: Danger
        uses: 417-72KI/danger-swiftlint@v6.2 # Look at the `Note for version`
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Note for version
> [!IMPORTANT]
> Docker images in `v5.9` and higher versions are updated for once a week.  
> `v5.8` and below also can be used in GitHub Actions, but Docker images of them are no longer updated.

| tag | Swift version |
| --- | ------------- |
| `v5.5+` | Same as the tag |
| `v4`    | 5.4 |
| `v3`    | 5.3 |
| `v2`    | 5.2 |
| `v1`    | 5.1 |
