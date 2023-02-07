# Universal metadata

By default on Fastlane we use `upload_to_app_store` & `upload_to_play_store` to publish metadata on the store. But each of them use different folder structure to achieve the same goal.

The goal of this Fastlane plugin is to unify metadata & screenshots structure for both iOS and Android, and finally produce metadata folder that will be used by `upload_to_app_store` & `upload_to_play_store`.
This is ideal for React Native or Flutter project.

# Features

- Generate every screenshot size derived from a single file
- Generate every metadata for both Android & iOS from a single json file

# Setup

1. First install the plugin by using `fastlane add_plugin universal_metadata`
2. Run the command `fastlane run universal_metdata init:true languages:"en-US,fr-FR"`, this will init the folder `universal-metadata` with this structure
    
    ```
    universal-metadata
    ├── screenshots
    │   └── default
    │   └── en-US
    │   └── fr-FR
    ├── description
    │   └── default
    │       ├── full_description.txt
    │       └── short_description.txt
    │   └── en-US
    │       └── ...
    │   └── fr-FR
    │       └── ...
    ├── release-notes
    │   ├── default.txt
    │   ├── en-US.txt
    │   └── fr-FR.txt
    └── metadata.json
    ```
    

# Configuration

## Metadata.json

Concerning metadata, most of things are configurable in the file `metadata.json`.

Sometime you will see that value are in the form `{ "default": "A value" }` in this case it means it’s a localized value and you can add translation for specific languages:

```json
{
	"default": "Hello world !",
	"fr-FR": "Bonjour le monde !"
}
```

If a value had a direct value, it means it cannot be translate.

## Others metadata

We decide to put descriptions & release-notes under specific files cause theses metadata are often multilines and so not very convenient to define in a JSON file.

You can define you description following this structure:

```
description
├── default
│   ├── full_description.txt
│   └── short_description.txt  <-- Android only
├── en-US
│   ├── full_description.txt
│   └── short_description.txt
└── fr-FR <-- Remove language folder to use default instead
    ├── full_description.txt
    └── short_description.txt
```

For release-notes it’s pretty close:

```
release-notes
├── default.txt
├── en-US.txt
└── fr-FR.txt <-- Remove language file to use default instead
```

## Screenshots

Screenshots folder has a similar structure:

```
screenshots
├── default
│   ├── 1-screenshot.png
│   └── 2-screenshot.png
├── en-US
└── fr-FR <-- Remove language folder to use default instead
```

During the action, your screenshots will be resized to match size required by iOS & Android and put it the good folder.

```
⚠️ Default folder is used only if the folder for language doesn’t exist (if language folder is empty, no screenshot will be uploaded).
```

You can configure screenshot behavior by adding tags in the name of the file :

| Tag | Description |
| --- | --- |
| tablet | Use the screenshot for tablet (without this tag it’s used only for phone) |
| contain | By default screenshot are resized with cover resizeMode. When the tag contain is present, screenshot will be resized with contain resizeMode (note for iOS, using contain tag can result to white border to match the exact size required by the App Store) |
| apple | If this tag is present, use the screenshot only for iOS |
| android | If this tag is present, use the screenshot only for Android |

So for example you can add a screenshot `random-name-apple-contain.png` that will be use only for iOS and use resizeMode contain.

```
ℹ️ The order of the screenshots on the store depends of alphabetical order of the screenshots names.
```

## Result

By running `fastlane run universal_metdata languages:"en-US,fr-FR"` you will get the following result:

```
screenshots
│   └── fr
│       ├── screen-1.png
│       └── screen-2.png
metadata
├── android
│   └── fr
│       ├── images
│       │   ├── phoneScreenshots
│       │   │   ├── screen-1.png
│       │   │   └── screen-2.png
│       │   ├── sevenInchScreenshots
│       │   │   ├── screen-1.png
│       │   │   └── screen-2.png
│       │   └── tenInchScreenshots
│       │   │   ├── screen-1.png
│       │   │   └── screen-2.png
│       ├── full_description.txt
│       ├── short_description.txt
│       ├── title.txt
│       └── video.txt
├── fr
│   ├── name.txt
│   ├── subtitle.txt
│   ├── privacy_url.txt
│   ├── description.txt
│   ├── keywords.txt
│   ├── release_notes.txt
│   ├── support_url.txt
│   ├── marketing_url.txt
│   └── promotional_text.txt
├── copyright.txt
├── primary_category.txt
├── secondary_category.txt
├── primary_first_sub_category.txt
├── primary_second_sub_category.txt
├── secondary_first_sub_category.txt
├── secondary_second_sub_category.txt
├── first_name.txt
├── last_name.txt
├── phone_number.txt
├── email_address.txt
├── demo_user.txt
├── demo_password.txt
└── notes.txt
```

Now you are able to run `upload_to_app_store` & `upload_to_play_store` without pain.

```
ℹ️ Don’t forget that you can use universal_metadata action in your lane, before uploading to store for example 😉
```

## Params

You can use different params with the action:

| Param | ENV Variable | Description | Default |
| --- | --- | --- | --- |
| languages | LANGUAGES | List of languages to use (comma-separated) |  |
| ios_screenshots_dir | IOS_SCREENSHOTS_DIR | The target dir for ios screenshots | fastlane/screenshots |
| skip_screenshots_resize | SKIP_SCREENSHOTS_RESIZE | Don’t resize screenshot if true | false |
| skip_screenshots | SKIP_SCREENSHOTS | Don’t manage screenshot at all if true | false |

## Tips & Warning

```
⚠️ Your metadata folder will be erased each time you run the action, be sure to not having sensitive data on it. Also since it will be auto-generated, we recommend to add it to your `.gitignore`
```
```
ℹ️ Personally I like to have all the result under fastlane/metadata, that’s why i use the `ios_screenshots_dir` params with the value `fastlane/metadata/screenshots`.
```

Because it’s not the default place for it, I have to add this to my Deliverfile:

```
# Cause we use non-standard path for screenshots, we have to add this options
ignore_language_directory_validation(true)
screenshots_path("./fastlane/metadata/screenshots")

# Prevent same screenshot from being uploaded multiple times
overwrite_screenshots(true)
```
