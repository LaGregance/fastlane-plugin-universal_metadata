describe Fastlane::Actions::UniversalMetadataAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The universal_metadata plugin is working!")

      Fastlane::Actions::UniversalMetadataAction.run(nil)
    end
  end
end
