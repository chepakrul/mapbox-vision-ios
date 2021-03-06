[![Secret-shield enabled](https://github.com/mapbox/secret-shield/blob/assets/secret-shield-enabled-badge.svg)](https://github.com/mapbox/secret-shield/blob/master/docs/enabledBadge.md)
![Swift version](https://img.shields.io/static/v1.svg?label=Swift&message=4.2&color=orange)
![Platform support](https://img.shields.io/static/v1.svg?label=iOS&message=%3E=%2011.2&color=brightgreen)

# Mapbox Vision SDK

# Table of contents

- [Overview](#overview)
- [Getting Started](#getting-started)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [Versioning](#versioning)
- [License](#license)

# Overview

The current repository is a part of [Mapbox Vision SDK](https://vision.mapbox.com).

Mapbox Vision SDK provides developers with cutting-edge AI and AR tools to build better driving experiences. It’s smart enough to understand the road, yet lean enough to run on devices that billions of drivers use everyday.

The key features are:
- Navigation in augemented reality;
- Scene segmentation;
- Sign detection;
- Safety alerts;
- Object detection;
- Lane detection.

# Getting Started

## Requirements

The Vision SDK for iOS is written in Swift 4.2 and can be used with:
  - iOS 11.2 and higher;
  - iPhone 6s or newer.
  
You can find all requirements at [Documentation page](https://docs.mapbox.com/ios/vision/overview/#requirements).

## Installation process

To set up the Vision SDK you will need to download the SDK, install the frameworks relevant to your project, and complete a few configuration steps. You can find all details at [Documentation page](https://docs.mapbox.com/ios/vision/overview/#getting-started).

# Documentation

The lastest version of documentation is available at [Vision's page](https://docs.mapbox.com/ios/vision).

# Contributing

We use [secret-shield](https://github.com/mapbox/secret-shield) tool which runs as a pre-commit hook. In order to enable it you should install it with:
```sh
npm install -g @mapbox/secret-shield
```

Then you have to add a pre-commit git hook. The simplest option is to copy the following script into a `mapbox-vision-ios/.git/hooks/pre-commit`:
```sh
#!/bin/sh
secret-shield --pre-commit -C verydeep --enable "Mapbox Public Key" --disable "High-entropy base64 string" "Short high-entropy string" "Long high-entropy string"
```

Don't forget to make it executable:
```sh
chmod +x .git/hooks/pre-commit
```

As an option you can Integrate hook via git hooks manager (like [Husky](https://github.com/typicode/husky) or [Komondor](https://github.com/shibapm/Komondor)).
More information about installation is available [here](https://github.com/mapbox/secret-shield#install).

## Code of conduct

Everyone is invited to participate in Mapbox's open source projects and public discussions: we want to create a welcoming and friendly environment. Harassment of participants or other unethical and unprofessional behavior will not be tolerated in our spaces.

The [Contributor Covenant](https://www.contributor-covenant.org) applies to all projects under the Mapbox organization whether they explicitly include the Contributor Covenant's [CODE_OF_CONDUCT.md](https://www.contributor-covenant.org/version/1/4/code-of-conduct.html) or not.

# Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on repository](https://github.com/mapbox/mapbox-vision-ios/tags).

Changes in repository is in sync with changes in Vision Core library (which is under-the-hood of Vision SDK).

# License

For details, read [LICENSE file](LICENSE.md).
