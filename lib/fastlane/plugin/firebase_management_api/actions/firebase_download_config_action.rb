module Fastlane
	module Actions
		class FirebaseManagementDownloadConfigAction < Action

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

				# select project
				project_id = params[:project_id] || manager.select_project(nil)["projectId"]

				# select type
				type = params[:type].to_sym

				# select app
				app_id = params[:app_id] || manager.select_app(project_id, nil, type)["appId"]

				# download
				case type
				when :ios
					config = api.download_ios_config_file(project_id, app_id)
				when :android
					config = api.download_android_config_file(project_id, app_id)
				end
				
				path = File.join(params[:output_path], params[:output_name] || config["configFilename"])

				decode_base64_content = Base64.decode64(config["configFileContents"]) 
				File.open(path, "wb") do |f|
					f.write(decode_base64_content)
				end 

				UI.success "Successfuly saved config at #{path}"

				return nil
			end

			def self.description
				"Download configuration file for Firebase app"
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
					                        optional: true),

					FastlaneCore::ConfigItem.new(key: :project_id,
					                        env_name: "FIREBASE_PROJECT_ID",
					                     description: "Project id",
					                        optional: true),

					FastlaneCore::ConfigItem.new(key: :app_id,
					                        env_name: "FIREBASE_APP_ID",
					                     description: "Project app id",
					                        optional: true),

					FastlaneCore::ConfigItem.new(key: :type,
											env_name: "FIREBASE_TYPE",
										 description: "Type of client (ios, android)",
											verify_block: proc do |value|
												types = [:ios, :android]
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
