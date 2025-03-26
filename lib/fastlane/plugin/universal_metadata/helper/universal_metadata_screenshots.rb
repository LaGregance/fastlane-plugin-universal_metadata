require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class UniversalMetadataScreenshots
      def self.generateScreenshots(languages, params, metadata_folder)
        if params[:skip_screenshots] then
          UI.message("Skip screenshots")
          return
        end

        ios_screenshot_folder = params[:ios_screenshots_dir]
        FileUtils.rm_rf(ios_screenshot_folder)
        FileUtils.mkdir_p(ios_screenshot_folder)

        screenSizes = {
          # Apple
          "iPhone-6_5" => { "isTablet" => false, "width" => 1242, "height" => 2688, "isApple" => true },
          # "iPhone-6_7" => { "isTablet" => false, "width" => 1290, "height" => 2796, "isApple" => true },
          # "iPhone-6_1" => { "isTablet" => false, "width" => 1179, "height" => 2556, "isApple" => true },
          # "iPhone-5_8" => { "isTablet" => false, "width" => 1170, "height" => 2532, "isApple" => true },
          "iPhone-5_5" => { "isTablet" => false, "width" => 1242, "height" => 2208, "isApple" => true },
          "iPad-12_9" => { "isTablet" => true, "width" => 2048, "height" => 2732, "isApple" => true },
          "ipadPro129" => { "isTablet" => true, "width" => 2048, "height" => 2732, "isApple" => true },
          # "iPad-11" => { "isTablet" => true, "width" => 1668, "height" => 2388, "isApple" => true },

          # Android
          "android-5_8" => { "isTablet" => false, "width" => 1242, "height" => 2208, "isApple" => false, "folder" => 'phoneScreenshots' },
          "android-7" => { "isTablet" => true, "width" => 2048, "height" => 2732, "isApple" => false, "folder" => 'sevenInchScreenshots' },
          "android-11" => { "isTablet" => true, "width" => 2048, "height" => 2732, "isApple" => false, "folder" => 'tenInchScreenshots' },
        }

        for lang in languages
          for screenshot in self.getScreenshotFiles(lang) do
            tags = self.getScreenshotTags(screenshot)

            screenSizes.each do |deviceName, deviceInfo|
              if tags["isApple"] == deviceInfo["isApple"] || tags["isAndroid"] != deviceInfo["isApple"] then
                if deviceInfo["isApple"] then
                  targetFolder = File.join(ios_screenshot_folder, lang)
                else
                  targetFolder = File.join(metadata_folder, 'android', lang, 'images', deviceInfo["folder"])
                end

                FileUtils.mkdir_p(targetFolder)
                if params[:skip_screenshots_resize] then
                  FileUtils.cp(screenshot, File.join(targetFolder, File.basename(screenshot)))
                else
                  if deviceInfo["isTablet"] == tags["isTablet"] then
                    self.resizeImage(
                      screenshot,
                      File.join(targetFolder, deviceName + '-' + File.basename(screenshot)),
                      deviceInfo["width"],
                      deviceInfo["height"],
                      tags["resizeContain"],
                      deviceInfo["isApple"]
                    )
                  end
                end
              end
            end
          end
        end
      end

      def self.getScreenshotTags(file)
        file = File.basename(file).downcase
        tags = {
          "isTablet" => file.include?('tablet'),
          "resizeContain" => file.include?('contain'),
          "isApple" => file.include?('apple') || !file.include?('android'),
          "isAndroid" => file.include?('android') || !file.include?('apple'),
        }
        tags
      end

      def self.getScreenshotFiles(lang)
        folder = File.join(Helper::UniversalMetadataConst.universal_metadata_folder, 'screenshots')

        if File.exist?(File.join(folder, lang)) then
          # Nothing
        elsif File.exist?(File.join(folder, 'default')) then
          lang = 'default'
        else
          puts "Warning: " + lang + ' or default not found for screenshots'
          return []
        end

        return Dir.entries(File.join(folder, lang))
                  .select{ |f| !%w[. ..].include?(f) }
                  .map { |file| File.join(folder, lang, file) }
      end

      def self.resizeImage(source, target, width, height, resizeContain, addBorder)
        size = width.to_s + 'x' + height.to_s

        # Add ^ just after the size make the resizeMode to cover (default contain)
        cmd = 'magick convert "'+source+'" -resize ' + size + (resizeContain ? '' : '^')
        if addBorder then
          cmd += ' -gravity center -extent '+size
        end
        cmd += ' "'+target+'"'

        result = system(cmd)
        if !result then
          puts "Warning: Error resizing file " + source
        end
      end

    end
  end
end
