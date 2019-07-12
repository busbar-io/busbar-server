# CHANGELOG

## [1.9.7-5] - 2019-07-12
### Fix
- Fix 'destroy' application method - Add checking to not fail in case component doesn't exist
- Fix busbar Docker build - fix apt repository string

## [1.9.7-4] - 2019-01-16
### Fix
- Fix CORS policy for Put and enabled it on /scale

## [1.9.7-3] - 2019-01-15
### Add
- Add Nodes API endpoint

## [1.9.7-2] - 2019-01-15
### Add
- Add CORS header

### Fix
- Fix deploy key being added to the compiled image

## [1.9.7-1] - 2019-01-14
### Add
- Add componentes data on the environment API output

### Fix
- Fix JazzFingers initializer

## [1.9.7] - 2018-09-20
### Fixed
- The resource allocation for the nginx web frontends

## [1.9.6] - 2018-09-19
### Add
- Node type added to the manifest labels

## [1.9.5] - 2018-07-02
### Add
- Node version 8 support

## [1.9.4] - 2018-06-22
### Fix
- Fix sproute version: 3.7.1 > 3.7.2 - CVE-2018-3760

## [1.9.3] - 2018-06-22
### Add
- Node version 10 support

### Upgrade
- Update Rubocop to version 0.49 - CVE-2017-8418

## [1.9.2] - 2018-04-02
### Fix
- Java buildpack detection

## [1.9.1] - 2018-03-28
### Fix
- local interface implemented

## [1.9.0] - 2018-03-21
### Upgrade
- Upgrade kubernetes to 1.9.6

## [1.8.2] - 2018-03-21
### Fix
- Fix Gemfile.lock vulnerabilities

### Upgrade
- Upgrade kubernetes to 1.8.10

## [1.8.1] - 2017-12-15
### Fix
- Add missing require statement
- Remove '-f' from docker tag command

## [1.8.0] - 2017-12-14
### Upgrade
- Upgrade kubernetes to 1.8.5

## [1.7.0] - 2017-12-14
### Upgrade
- Upgrade kubernetes to 1.7.11

## [1.6.0] - 2017-12-14
### Upgrade
- Upgrade docker to 1.13.1 and kubernetes to 1.6.13

## [1.5.2] - 2017-11-16
### Fix
- Gems security update

## [1.5.1] - 2017-11-16
### Fix
- Make SSL_CERTIFICATE optional

### Add
- Add config/deploy.pem to .gitignore

## [1.5.0] - 2017-11-01
### Add
- Initial Release
