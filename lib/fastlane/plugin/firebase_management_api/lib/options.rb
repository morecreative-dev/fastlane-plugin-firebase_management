require 'fastlane_core'
require 'credentials_manager'

module FirebaseManagement
	class Options
		def self.available_options
			[
				FastlaneCore::ConfigItem.new(
					key: :username,
					env_name: "FIREBASE_USERNAME",
					description: "Username for the google account"
				)
			]
		end
	end
end
