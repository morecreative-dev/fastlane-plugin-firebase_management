module Fastlane
	module Actions
		class FirebaseManagementApiUploadShaAction < Action
			
			def self.run(params)
				manager = FirebaseManagementApi::Manager.new
				
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

				# select project
				project_id = params[:project_id] || manager.select_project(nil)["projectId"]
				
				# select app
				app_id = params[:app_id] || manager.select_app(project_id, nil, :android)["appId"]

				# create new android app on Firebase
				api.upload_sha(project_id, app_id, params[:sha_hash], params[:cert_type])

				if params[:download_config] then
					#Download config
					Actions::FirebaseManagementApiDownloadConfigAction.run(
						service_account_json_path: params[:service_account_json_path],
						project_id: project_id,
						app_id: app["appId"],
						type: type,
						output_path: params[:output_path]
					)
				end
			end

			def self.description
				"Add sha to to Firebase android app"
			end

			def self.authors
				["NicoLourenco"]
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
											optional: true),

					FastlaneCore::ConfigItem.new(key: :project_id,
											env_name: "FIREBASE_PROJECT_ID",
										 description: "Project id",
											optional: true),

					FastlaneCore::ConfigItem.new(key: :app_id,
											env_name: "FIREBASE_APP_ID",
										 description: "Project app id",
											optional: true),

					FastlaneCore::ConfigItem.new(key: :sha_hash,
											env_name: "FIREBASE_SHA_HASH",
										 description: "Sha hash",
											optional: false),

					FastlaneCore::ConfigItem.new(key: :download_config,
											env_name: "FIREBASE_DOWNLOAD_CONFIG",
										 description: "Should download config for created client",
											optional: false,
											is_string: false,
											default_value: false),

					FastlaneCore::ConfigItem.new(key: :cert_type,
											env_name: "FIREBASE_CERT_TYPE",
										 description: "Type of certificate (SHA_1, SHA_256)",
										 optional: false,
											verify_block: proc do |value|
												types = [:SHA_1, :SHA_256]
												UI.user_error!("Type must be in #{types}") unless types.include?(value.to_sym)
											end
										 ),

					FastlaneCore::ConfigItem.new(key: :output_path,
					                        env_name: "FIREBASE_OUTPUT_PATH",
					                     description: "Path for the downloaded config",
					                        optional: false,
					                   default_value: "./"),

					FastlaneCore::ConfigItem.new(key: :output_name,
					                        env_name: "FIREBASE_OUTPUT_NAME",
					                     description: "Name of the downloaded file",
					                        optional: true)
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
