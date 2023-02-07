require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class UniversalMetadataInit
      # class methods that you define here become available in your action
      # as `Helper::UniversalMetadataInit.your_method`
      #
      def self.init(languages)
        folder = Helper::UniversalMetadataConst.universal_metadata_folder
        if File.exist?(folder) then
          UI.error("Folder universal-metadata already exists")
          return
        end

        UI.message("Init universal-metadata folder")

        # 1. Create file tree
        FileUtils.mkdir_p(File.join(folder, 'screenshots/default'))

        FileUtils.mkdir_p(File.join(folder, 'release-notes'))
        File.write(File.join(folder, 'release-notes', 'default.txt'), "Default release note")

        FileUtils.mkdir_p(File.join(folder, 'description/default'))
        File.write(File.join(folder, 'description/default', 'full_description.txt'), "Default full description")
        File.write(File.join(folder, 'description/default', 'short_description.txt'), "Default short description")

        for lang in languages
          FileUtils.mkdir_p(File.join(folder, 'screenshots', lang))

          FileUtils.mkdir_p(File.join(folder, 'description', lang))
          File.write(File.join(folder, 'description', lang, 'full_description.txt'), lang + " full description")
          File.write(File.join(folder, 'description', lang, 'short_description.txt'), lang + " short description")

          File.write(File.join(folder, 'release-notes', lang+'.txt'), lang + " release note")
        end

        # 2. Create metadata.json
        metadata = {
          "name": {
            "default": "AppName"
          },
          "subtitle": {
            "default": ""
          },
          "privacy_url": {
            "default": ""
          },
          "copyright": "2023 La Gregance",
          "apple": {
            "primary_category": "",
            "secondary_category": "",
            "primary_first_sub_category": "",
            "primary_second_sub_category": "",
            "secondary_first_sub_category": "",
            "secondary_second_sub_category": "",
            "keywords": {
              "default": ""
            },
            "support_url": {
              "default": ""
            },
            "marketing_url": {
              "default": ""
            },
            "promotional_text": {
              "default": ""
            },
            "reviewInfos": {
              "first_name": "",
              "last_name": "",
              "phone_number": "",
              "email_address": "",
              "demo_user": "",
              "demo_password": "",
              "notes": ""
            }
          }
        }
        File.write(File.join(folder, 'metadata.json'), JSON.pretty_generate(metadata))
      end
    end
  end
end
