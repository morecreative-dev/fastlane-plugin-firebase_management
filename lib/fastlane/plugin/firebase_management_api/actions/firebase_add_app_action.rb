module Fastlane
	module Actions
		class FirebaseManagementAddAppAction < Action
			
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

				bundle_id = params[:bundle_id]

				display_name = params[:display_name]

				case type
				when :ios
					# download apps for project
					apps = api.ios_app_list(project_id)

					# search for newly created app
					app = apps.detect {|app| app["bundleId"] == bundle_id }
					
					UI.success "Start detect app "

					if app != nil then
						UI.success "You already have app with id: #{app["appId"]}"
					else
						UI.success "Start create new app "

						# create new ios app on Firebase
						api.add_ios_app(project_id, bundle_id, display_name)

						# App creation is a long-running operation.
						# Creation endpoint returns operation ID which should be used to check
						# the result of the operation. This requires another Google API to be
						# enabled and other stuff to do so just wait for 3 seconds here, fetch
						# apps from Firebase and check whether the new app is there.
						sleep 3

						# download apps for project
						apps = api.ios_app_list(project_id)

						# search for newly created app
						app = apps.detect {|app| app["bundleId"] == bundle_id }
						# present result to user
						if app != nil then
							UI.success "New app with id: #{app["appId"]} successfully created"
						else
							UI.crash! "Unable to create new app"
						end
					end
						

				when :android
						
					# download apps for project
					apps = api.android_app_list(project_id)

					# search for newly created app
					app = apps.detect {|app| app["packageName"] == bundle_id }
							
					if app != nil then
						UI.success "You already have app with id: #{app["appId"]}"
					else
						
						# create new android app on Firebase
						api.add_android_app(project_id, bundle_id, display_name)

						# see reason described above
						sleep 3	
						
						# download apps for project
						apps = api.android_app_list(project_id)

						# search for newly created app
						app = apps.detect {|app| app["packageName"] == bundle_id }

						# present result to user
						if app != nil then
							UI.success "New app with id: #{app["appId"]} successfully created"
						else
							UI.crash! "Unable to create new app"
						end
					end

				end

				if params[:download_config] then
					#Download config
					Actions::FirebaseManagementDownloadConfigAction.run(
						service_account_json_path: params[:service_account_json_path],
						project_id: project_id,
						app_id: app["appId"],
						type: type,
						output_path: params[:output_path]
					)
				end
			end

			def self.description
				"Add new app to Firebase project"
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

					FastlaneCore::ConfigItem.new(key: :download_config,
											env_name: "FIREBASE_DOWNLOAD_CONFIG",
										 description: "Should download config for created client",
											optional: false,
											is_string: false,
											default_value: false),

					FastlaneCore::ConfigItem.new(key: :type,
											env_name: "FIREBASE_TYPE",
										 description: "Type of client (ios, android)",
											verify_block: proc do |value|
												types = [:ios, :android]
												UI.user_error!("Type must be in #{types}") unless types.include?(value.to_sym)
											end
										 ),
					FastlaneCore::ConfigItem.new(key: :bundle_id,
											env_name: "FIREBASE_BUNDLE_ID",
										 description: "Bundle ID (package name)",
											optional: false),

					FastlaneCore::ConfigItem.new(key: :display_name,
											env_name: "FIREBASE_DISPLAY_NAME",
										 description: "Display name",
											optional: true),

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
