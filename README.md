# firebase_management_api `fastlane` Plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-firebase_management_api)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-firebase_management_api`, add it to your project by running:

```bash
fastlane add_plugin firebase_management_api
```

## About firebase_management_api

An unofficial tool to access Firebase project settings. It allows you to create new apps and download config files (GoogleInfo.plist for ios and google-services.json for android).

Plugin uses new official [Firebase Management API](https://firebase.google.com/docs/projects/api/reference/rest/) introduced on Firebase Summit 10/2018. It's based on [tkohout/fastlane-firebase-plugin](https://github.com/tkohout/fastlane-firebase-plugin), which uses web scraping instead of official API to manage Firebase apps. The plan is that both plugins will live next to each other until official API will contain all desired features and tkohout's plugin won't be needed anymore.

New features like deleting apps or APNs keys/certificates management are promised by guys from Google/Firebase so stay tuned 🤙

**This very first version was developed using alpha version of the API in a very short time, so it may contain bugs or mistakes. Issues and PRs are very welcome! 🤗**

### Actions

List all projects and apps

```
firebase_management_api_list
```

Add app to a project and download config file

```
firebase_management_api_add_app
```

Add sha to an android app and download config file

```
firebase_management_api_upload_sha
```

Download config file for a client

```
firebase_management_api_download_config
```

### Authentication

~~Plugin works only with service accounts.~~

#### User login

You can use your ordinary account in combination with client secret json file created in GCP console.

#### Service accounts

A service account is a special Google account that belongs to your application or a virtual machine, instead of to an individual end user. Read more [here](https://cloud.google.com/iam/docs/service-accounts).

All you need for the plugin to work is a json file with service account private key information. The easiest way to get it is...

Go to Firebase Console -> Your project -> Project settings -> Service accounts and tap on button `Generate new private key`. 🎉 That's the file you need!

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use

```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).

## Warning

DISCLAIMER OF WARRANTIES AND LIMITATION OF LIABILITY.

UNLESS OTHERWISE SEPARATELY UNDERTAKEN BY THE LICENSOR, TO THE EXTENT POSSIBLE, THE LICENSOR OFFERS THE LICENSED MATERIAL AS-IS AND AS-AVAILABLE, AND MAKES NO REPRESENTATIONS OR WARRANTIES OF ANY KIND CONCERNING THE LICENSED MATERIAL, WHETHER EXPRESS, IMPLIED, STATUTORY, OR OTHER. THIS INCLUDES, WITHOUT LIMITATION, WARRANTIES OF TITLE, MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, ABSENCE OF LATENT OR OTHER DEFECTS, ACCURACY, OR THE PRESENCE OR ABSENCE OF ERRORS, WHETHER OR NOT KNOWN OR DISCOVERABLE. WHERE DISCLAIMERS OF WARRANTIES ARE NOT ALLOWED IN FULL OR IN PART, THIS DISCLAIMER MAY NOT APPLY TO YOU.

TO THE EXTENT POSSIBLE, IN NO EVENT WILL THE LICENSOR BE LIABLE TO YOU ON ANY LEGAL THEORY (INCLUDING, WITHOUT LIMITATION, NEGLIGENCE) OR OTHERWISE FOR ANY DIRECT, SPECIAL, INDIRECT, INCIDENTAL, CONSEQUENTIAL, PUNITIVE, EXEMPLARY, OR OTHER LOSSES, COSTS, EXPENSES, OR DAMAGES ARISING OUT OF THIS PUBLIC LICENSE OR USE OF THE LICENSED MATERIAL, EVEN IF THE LICENSOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH LOSSES, COSTS, EXPENSES, OR DAMAGES. WHERE A LIMITATION OF LIABILITY IS NOT ALLOWED IN FULL OR IN PART, THIS LIMITATION MAY NOT APPLY TO YOU.

THE DISCLAIMER OF WARRANTIES AND LIMITATION OF LIABILITY PROVIDED ABOVE SHALL BE INTERPRETED IN A MANNER THAT, TO THE EXTENT POSSIBLE, MOST CLOSELY APPROXIMATES AN ABSOLUTE DISCLAIMER AND WAIVER OF ALL LIABILITY.
