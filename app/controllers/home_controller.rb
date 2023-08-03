class HomeController < ApplicationController
  before_action :require_current_user, only: [:index]

  def index
    url = URI("https://sandbox.dev.clover.com/v3/merchants/#{current_user.merchant_id}/cash_events")

    http                     = Net::HTTP.new(url.host, url.port)
    http.use_ssl             = true
    request                  = Net::HTTP::Get.new(url)
    request['accept']        = 'application/json'
    request['authorization'] = "Bearer #{current_user.token}"

    response = http.request(request)

    @cash_events = response.read_body
  end

  def authorize
    user = User.find_or_create_by(merchant_id: params[:merchant_id])

    user.update(verification_code: params[:code])

    uri = URI("#{ENV['CLOVER_OAUTH_URL']}/token")

    uri.query = URI.encode_www_form(
      client_id: ENV['CLOVER_APP_ID'],
      client_secret: ENV['CLOVER_APP_SECRET'],
      code: user.verification_code
    )

    res = Net::HTTP.get_response(uri)

    user.update(token: JSON.parse(res.body)['access_token']) if res.is_a?(Net::HTTPSuccess)

    session_user_id = user.id

    redirect_to root_path
  end

  def login
    @clover_oauth_url= "#{ENV['CLOVER_OAUTH_URL']}/authorize?client_id=#{ENV['CLOVER_APP_ID']}"
  end

  def logout
    session_user_id = nil

    redirect_to login_path
  end
end
