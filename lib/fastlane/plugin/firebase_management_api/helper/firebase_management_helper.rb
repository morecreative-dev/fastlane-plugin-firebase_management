require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class FirebaseManagementApiHelper
      # class methods that you define here become available in your action
      # as `Helper::FirebaseManagementApiHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the firebase_management plugin helper!")
      end
    end
  end
end
