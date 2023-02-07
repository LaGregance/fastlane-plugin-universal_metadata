require 'fastlane/action'
require_relative '../helper/universal_metadata_metadata'

module Fastlane
  module Actions
    class UniversalMetadataAction < Action
      def self.run(params)
        languages = params[:languages].split(',')

        if params[:init] then
          Helper::UniversalMetadataInit.init(languages)
          return
        end

        universal_metadata_folder = Helper::UniversalMetadataConst.universal_metadata_folder
        metadata_folder = Helper::UniversalMetadataConst.metadata_folder

        #####################################################
        ############## GENERATE METADATA FILES ##############
        #####################################################
        metadata = JSON.parse(File.read(File.join(universal_metadata_folder, 'metadata.json')))
        Helper::UniversalMetadataMetadata.generateMetadata(metadata, languages, metadata_folder)


        ######################################################
        ######### GENERATE SCREENSHOTS FOR EACH SIZE #########
        ######################################################
        Helper::UniversalMetadataScreenshots.generateScreenshots(languages, params, metadata_folder)
      end

      def self.description
        "Unify metadata files for iOS & Android"
      end

      def self.authors
        ["La Gregance"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Unify metadata files for iOS & Android"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :init,
                               description: "Init universal-metadata folder",
                               optional: true,
                               default_value: false,
                               type: Boolean),
          FastlaneCore::ConfigItem.new(key: :languages,
                               env_name: "LANGUAGES",
                               description: "Languages to which generate metadata folder (comma separated)",
                               optional: false,
                               type: String),
          FastlaneCore::ConfigItem.new(key: :ios_screenshots_dir,
                               env_name: "IOS_SCREENSHOTS_DIR",
                               description: "Folder that will store the screenshots for iOS",
                               optional: true,
                               default_value: "fastlane/screenshots",
                               type: String),
          FastlaneCore::ConfigItem.new(key: :skip_screenshots_resize,
                               env_name: "SKIP_SCREENSHOTS_RESIZE",
                               description: "If true, we don't resize screenshots before moving them",
                               optional: true,
                               default_value: false,
                               type: Boolean),
          FastlaneCore::ConfigItem.new(key: :skip_screenshots,
                               env_name: "SKIP_SCREENSHOTS",
                               description: "If true, skip copying screenshot",
                               optional: true,
                               default_value: false,
                               type: Boolean)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
