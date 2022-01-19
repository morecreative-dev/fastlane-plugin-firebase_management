module Fastlane
	module FirebaseManagement
		class Manager

			require 'googleauth'
			require 'googleauth/stores/file_token_store'

			def userLogin(email, client_secrets_path)

				system 'mkdir -p ~/.google'

				oob_uri = "urn:ietf:wg:oauth:2.0:oob"

				scopes = [
					'https://www.googleapis.com/auth/firebase',
					'https://www.googleapis.com/auth/cloud-platform'
				]
				client_id = Google::Auth::ClientId.from_file(client_secrets_path)
				token_store = Google::Auth::Stores::FileTokenStore.new(:file => File.expand_path("~/.google/tokens.yaml"))
				authorizer = Google::Auth::UserAuthorizer.new(client_id, scopes, token_store)

				credentials = authorizer.get_credentials(email)
				if credentials.nil?
				  url = authorizer.get_authorization_url(base_url: oob_uri)
				  UI.message "Open #{url} in your browser and enter the resulting code."

				  code = Fastlane::Actions::PromptAction.run(text: "Code: ")

				  credentials = authorizer.get_and_store_credentials_from_code(user_id: email, code: code, base_url: oob_uri)
				end
				
				token = credentials.fetch_access_token!["access_token"]
				@api = FirebaseManagement::Api.new(token)
				@api
			end

			def serviceAccountLogin(jsonPath)
				scope = 'https://www.googleapis.com/auth/firebase https://www.googleapis.com/auth/cloud-platform'

				authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
					json_key_io: File.open(jsonPath),
					scope: scope
				)

				token = authorizer.fetch_access_token!["access_token"]
				@api = FirebaseManagement::Api.new(token)
				@api
			end

			def select_project(project_id)

				projects = @api.project_list()
				
				if projects.count == 0 then
					UI.user_error! "No projects exist under the account"
					return
				end

				if project = projects.select {|p| p["projectId"] == project_id }.first then
					project
				else 
					options = projects.map { |p| "#{p["displayName"]} (#{p["projectId"]})" }
					index = select_index("Select project:", options)
					projects[index]
				end
			end

			def select_app(project_id, app_id, type)

				case type
				when :ios
					apps = @api.ios_app_list(project_id)
				when :android
					apps = @api.android_app_list(project_id)
				end

				if apps.empty? then
					UI.user_error! "Project has no #{type} apps"
					return
				end

				apps = apps.sort {|left, right| left["appId"] <=> right["appId"] }

				if app = apps.select {|a| a["appId"] == app_id }.first then
					app
				else
					options = apps.map { |a| "#{a["displayName"] || a["bundleId"] || a["packageName"]} (#{a["appId"]})" }
					index = select_index("Select app:", options)
					apps[index]
				end
			end

			def select_index(text, options)
				selected = UI.select(text, options)
				return options.index(selected)
			end 
		end
	end
end 
