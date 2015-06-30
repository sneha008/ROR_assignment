require 'ping'
require 'net/http'
require 'timeout'
require 'socket'

class TargetsController < ApplicationController
    caches_page :target_status

	def target_status
		@targets = Target.limit(50)
		@targets_grid = initialize_grid(@targets,
			:order => "hostname",
			:enable_export_to_csv => true,
			:include => :appliance,
			:name => "grid",
			:csv_file_name => "targets",
			:per_page => "10")

		export_grid_if_requested('grid' => 'targets_list')

		unless(params[:grid] || params[:search] || params[:page] || params[:per_page])
			@targets.each do |target|
				pingecho(target.hostname)
			end
		end
		expires_in 3.minutes, :public => true
	end

	# class Ping
  def pingecho(host, timeout=2, service="echo")
    puts host
    @cnt = 0
    begin
      timeout(timeout) do
        s = TCPSocket.new(host, service)
        s.close
        return true
      end
    rescue Errno::ECONNREFUSED
      return true
    rescue Timeout::Error, StandardError
      return false
    end
    @cnt+=1
  end

end
