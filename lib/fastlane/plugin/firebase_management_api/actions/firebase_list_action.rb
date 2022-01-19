module Fastlane
	module Actions
		class FirebaseManagementListAction < Action

			def self.run(params)
				manager = FirebaseManagement::Manager.new

				# login
				api = nil
				if params[:service_account_json_path] != nil then
					api = manager.serviceAccountLogin(params[:service_account_json_path])
				elsif params[:email] != nil && params[:client_secret_json_path] != nil then
					api = manager.userLogin(params[:email], params[:client_secret_json_path])
				else
					UI.error "You must define service_account_json_path or email with client_secret_json_path."
					return nil
				end

				# download list of projects
				projects = api.project_list()

				# create formatted output
				projects.each_with_index { |p, i| 
					UI.message "#{i+1}. #{p["displayName"]} (#{p["projectId"]})" 
					
					ios_apps = api.ios_app_list(p["projectId"])
					if !ios_apps.empty? then
						UI.message "  iOS"
						ios_apps.sort {|left, right| left["appId"] <=> right["appId"] }.each_with_index { |app, j|
							UI.message "  - #{app["displayName"] || app["bundleId"]} (#{app["appId"]})" 
						}
					end

					android_apps = api.android_app_list(p["projectId"])
					if !android_apps.empty? then
						UI.message "  Android"
						android_apps.sort {|left, right| left["appId"] <=> right["appId"] }.each_with_index { |app, j|
							UI.message "  - #{app["displayName"] || app["packageName"]} (#{app["appId"]})" 
						}
					end
				}

				return nil
			end

			def self.description
				"List all Firebase projects and their apps"
			end

			def self.authors
				["Ackee, s.r.o."]
			end

			def self.return_value
				# If your method provides a return value, you can describe here what it does
			end

			def self.details
				# Optional:
				"Firebase plugin helps you list your projects, create applications and download configuration files."
			end

			def self.available_options
				[
					FastlaneCore::ConfigItem.new(key: :email,
											env_name: "FIREBASE_EMAIL",
										 description: "User's email to identify stored credentials",
											optional: true),

					FastlaneCore::ConfigItem.new(key: :client_secret_json_path,
											env_name: "FIREBASE_CLIENT_SECRET_JSON_PATH",
										 description: "Path to client secret json file",
											optional: true),

					FastlaneCore::ConfigItem.new(key: :service_account_json_path,
											env_name: "FIREBASE_SERVICE_ACCOUNT_JSON_PATH",
										 description: "Path to service account json key",
											optional: true
					)
				]
			end

			def self.is_supported?(platform)
				# Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
				# See: https://github.com/fastlane/fastlane/blob/master/fastlane/docs/Platforms.md
				#
				# [:ios, :mac, :android].include?(platform)
				true
			end
		end
	end
end
