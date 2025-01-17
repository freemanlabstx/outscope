class HandleReportJob < ApplicationJob
  queue_as :default

  def perform(id)
    businesses = []
    rate_limit_headers = {
      "ratelimit-dailylimit": Integer,
      "ratelimit-remaining": Integer,
      "ratelimit-reset-time": String,
    }
    req_threshold = 5

    @report = Report.find(id)
    @account = @report.account

    unless @account.can_create_report? || Rails.env.development?
      puts 'You have reached your limit of reports. Please upgrade your account.'
      @report.update!(status: :failed)
    end

    unless @report.report_type == 'yelp'
      puts 'Tried to create a report with an invalid report type.'
      @report.update!(status: :failed)
    end

    remaining = JumpstartApp::Application.redis.get("outscope:yelp:ratelimit-remaining") || 999 # :)
    if remaining < req_threshold
      begin
        reset_time_string = JumpstartApp::Application.redis.get("outscope:yelp:reset_time")
        reset_time = Date.parse(reset_time_string)
        HandleReportJob.set(wait_until: reset_time).perform_later(id)
        return
      rescue
        Rails.logger.warning("The reset_time passed from Yelp (persisted in Redis) is not Date parseable")
      end
    end

    @report.update!(status: :in_progress)

    params = {
      location: @report.location,
      term: @report.term,
      offset: 0
    }

    begin
      while (businesses.size + 50) < 200
        puts "Getting data from Yelp API... #{businesses.size} loaded so far"
        resp = Faraday.get('https://api.yelp.com/v3/businesses/search') do |req|
          req.headers['Authorization'] = "Bearer #{Rails.application.credentials.yelp[:api_key]}"
          req.params['location'] = params[:location]
          req.params['term'] = params[:term]
          req.params['limit'] = 50
          req.params['offset'] = params[:offset]
        end

        # Loop through all the headers we care about and persist their current vals in Redis
        rate_limit_headers.each do |header, klass|
          value = resp.headers[header]
          value = Integer(value) if klass == Integer
          JumpstartApp::Application.redis.set(
            "outscope:yelp:#{header}",
            resp.headers[header]
          )
        end

        data = JSON.parse(resp.body)

        break if data["businesses"].empty?
        businesses += data["businesses"]
        params[:offset] += 50
      end

      @report.update!(data: businesses.to_json, status: :done)

      @report.account.users.each do |user|
        ReportCompletedNotifier.with(
          report: @report,
          account: @report.account,
          user: user
        ).deliver(user)
      end
    rescue => e
      puts e
      @report.update!(status: :failed)
    end
  end
end
