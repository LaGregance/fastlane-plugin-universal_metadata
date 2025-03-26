require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class UniversalMetadataMetadata
      # class methods that you define here become available in your action
      # as `Helper::UniversalMetadataMetadata.your_method`
      #
      def self.generateMetadata(metadata, languages, metadata_folder)
        FileUtils.rm_rf(metadata_folder)
        FileUtils.mkdir_p(File.join(metadata_folder, 'android'))
        FileUtils.mkdir_p(File.join(metadata_folder, 'review_information'))

        # 1. Non localized files for iOS
        self.writeFile('copyright.txt', metadata['copyright'])
        self.writeFile('primary_category.txt', metadata['apple']['primary_category'])
        self.writeFile('secondary_category.txt', metadata['apple']['secondary_category'])
        self.writeFile('primary_first_sub_category.txt', metadata['apple']['primary_first_sub_category'])
        self.writeFile('primary_second_sub_category.txt', metadata['apple']['primary_second_sub_category'])
        self.writeFile('secondary_first_sub_category.txt', metadata['apple']['secondary_first_sub_category'])
        self.writeFile('secondary_second_sub_category.txt', metadata['apple']['secondary_second_sub_category'])

        self.writeFile('review_information/first_name.txt', metadata['apple']['reviewInfos']['first_name'])
        self.writeFile('review_information/last_name.txt', metadata['apple']['reviewInfos']['last_name'])
        self.writeFile('review_information/phone_number.txt', metadata['apple']['reviewInfos']['phone_number'])
        self.writeFile('review_information/email_address.txt', metadata['apple']['reviewInfos']['email_address'])
        self.writeFile('review_information/demo_user.txt', metadata['apple']['reviewInfos']['demo_user'])
        self.writeFile('review_information/demo_password.txt', metadata['apple']['reviewInfos']['demo_password'])
        self.writeFile('review_information/notes.txt', metadata['apple']['reviewInfos']['notes'])

        for lang in languages
          full_description = self.getDescription(true, lang)
          short_description = self.getDescription(false, lang)

          # 2. Localized files for iOS
          self.writeFile(lang + '/name.txt', self.localized(metadata['name'], lang))
          self.writeFile(lang + '/subtitle.txt', self.localized(metadata['subtitle'], lang))
          self.writeFile(lang + '/privacy_url.txt', self.localized(metadata['privacy_url'], lang))
          self.writeFile(lang + '/description.txt', full_description)
          self.writeFile(lang + '/keywords.txt', self.localized(metadata['apple']['keywords'], lang))
          self.writeFile(lang + '/release_notes.txt', self.getReleaseNotes(lang))
          self.writeFile(lang + '/support_url.txt', self.localized(metadata['apple']['support_url'], lang))
          self.writeFile(lang + '/marketing_url.txt', self.localized(metadata['apple']['marketing_url'], lang))
          self.writeFile(lang + '/promotional_text.txt', self.localized(metadata['apple']['promotional_text'], lang))

          # 3. Localized files for Android
          self.writeFile('android/' + lang + '/title.txt', self.localized(metadata['name'], lang))
          self.writeFile('android/' + lang + '/full_description.txt', full_description)
          self.writeFile('android/' + lang + '/short_description.txt', short_description)
          self.writeFile('android/' + lang + '/video.txt', "")
          self.writeFile('android/' + lang + '/changelogs/default.txt', self.getReleaseNotes(lang))
        end
      end

      def self.writeFile(file, content)
        file = 'fastlane/metadata/' + file
        FileUtils.mkdir_p(File.dirname(file))
        File.open(file, "w") { |f| f.write content }
      end

      def self.getDescription(full, lang)
        folder = 'fastlane/universal-metadata/description/'
        file = full ? '/full_description.txt' : '/short_description.txt'
        if File.exist?(folder + lang + file) then
          return File.read(folder + lang + file)
        elsif File.exist?(folder + 'default' + file) then
          return File.read(folder + 'default' + file)
        else
          puts "Warning: " + lang + ' or default not found for description'
          return ""
        end
      end

      def self.getReleaseNotes(lang)
        folder = File.join('fastlane/universal-metadata/release-notes/')

        if File.exist?(File.join(folder, lang + '.txt')) then
          return File.read(File.join(folder, lang + '.txt'))
        elsif File.exist?(File.join(folder, 'default.txt')) then
          return File.read(File.join(folder, 'default.txt'))
        else
          puts "Warning: " + lang + ' or default not found for release-notes'
          return ""
        end
      end

      def self.localized(metadata, lang)
        if metadata.key?(lang) then
          return metadata[lang]
        elsif metadata.key?('default') then
          return metadata['default']
        else
          puts "Warning: " + lang + ' or default not found in ' + metadata.to_s
          return ""
        end
      end

    end
  end
end
