module Fastlane
	module FirebaseManagement
		class Api 
			class LoginError < StandardError 
			end

			class BadRequestError < StandardError
				attr_reader :code
				
				def initialize(msg, code)
					@code = code
					super(msg)
				end
			end

			require 'googleauth'
			require 'httparty'

			def initialize(access_token)
				@base_url = "https://firebase.googleapis.com"
				@authorization_headers = {
					'Authorization' => 'Bearer ' + access_token
				}
			end

			def request_json(path, method = :get, parameters = Hash.new, headers = Hash.new)
				begin
					if method == :get then
						response = HTTParty.get("#{@base_url}/#{path}", headers: headers.merge(@authorization_headers), format: :plain)
					elsif method == :post then
						headers['Content-Type'] = 'application/json'
						response = HTTParty.post("#{@base_url}/#{path}", headers: headers.merge(@authorization_headers), body: parameters.to_json, format: :plain)
					end

					case response.code
						when 400...600
							UI.crash! response
						else
							JSON.parse(response)
					end

				rescue HTTParty::Error => e
					UI.crash! e.response.body
				rescue StandardError => e
					UI.crash! e
				end
			end

			def project_list
				UI.verbose "Retrieving project list"
				json = request_json("v1beta1/projects")
				projects = json["results"] || []
				UI.verbose "Found #{projects.count} projects"
				projects
			end
					
                        def ios_app_list(project_id, params = nil)
                                UI.verbose "Retrieving app list for project #{project_id}"

                                apps = []
                                pageToken = nil
                                loop do
                                        url = "v1beta1/projects/#{project_id}/iosApps" + (pageToken ? "?pageToken=#{pageToken}" : "")
                                        json = request_json(url)
                                        apps.concat(json["apps"] || [])
                                        pageToken = json["nextPageToken"]
                                        break if !pageToken
                                end
                                UI.verbose "Found #{apps.count} apps"
                                apps
                        end

                        def android_app_list(project_id)
                                UI.verbose "Retrieving app list for project #{project_id}"
                                apps = []
                                pageToken = nil
                                loop do
                                        url = "v1beta1/projects/#{project_id}/androidApps" + (pageToken ? "?pageToken=#{pageToken}" : "")
                                        json = request_json(url)
                                        apps.concat(json["apps"] || [])
                                        pageToken = json["nextPageToken"]
                                        break if !pageToken
                                end
                                UI.verbose "Found #{apps.count} apps"
                                apps
                        end

			def add_ios_app(project_id, bundle_id, app_name)
				parameters = {
					"bundleId" => bundle_id,
					"displayName" => app_name || ""
				}
				
				request_json("v1beta1/projects/#{project_id}/iosApps", :post, parameters)
			end

			def add_android_app(project_id, package_name, app_name)
				parameters = {
					"packageName" => package_name,
					"displayName" => app_name || ""
				}

				request_json("v1beta1/projects/#{project_id}/androidApps", :post, parameters)
			end

			def upload_sha(project_id, app_id, sha_hash, cert_type)
				UI.verbose "Uploading sha"
				parameters = {
					"shaHash" => sha_hash,
					"certType" => cert_type,
				}

				json = request_json("v1beta1/projects/#{project_id}/androidApps/#{app_id}/sha", :post, parameters)
				UI.verbose "Successfuly uploaded sha"
				json
			end

			def upload_certificate(project_number, client_id, type, certificate_value, certificate_password)
				
				prefix = type == :development ? "debug" : "prod"

				parameters = {
					"#{prefix}ApnsCertificate" => { 
						"certificateValue" => certificate_value,
						"apnsPassword" => certificate_password 
					}
				}

				json = request_json("v1/projects/#{project_number}/clients/#{client_id}:setApnsCertificate", :post, parameters)
			end

			def download_ios_config_file(project_id, app_id)
				UI.verbose "Downloading config file"
				json = request_json("v1beta1/projects/#{project_id}/iosApps/#{app_id}/config")
				UI.verbose "Successfuly downloaded #{json["configFilename"]}"
				json
			end

			def download_android_config_file(project_id, app_id)
				UI.verbose "Downloading config file"
				json = request_json("v1beta1/projects/#{project_id}/androidApps/#{app_id}/config")
				UI.verbose "Successfuly downloaded #{json["configFilename"]}"
				json
			end
		end
	end
end
