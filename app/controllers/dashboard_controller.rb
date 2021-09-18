class DashboardController < ApplicationController
  def new
  end

  def index
    @user = params[:user] || 'hola'
  end

  def grant
    h = handle_response(Api::Client.new(params).grant)

    flash[:success] = "Old balance: #{h['old_balance']}, New balance: #{h['new_balance']}"
    redirect_to controller: 'dashboard', action: 'index', user: h['user']
  end

  def redeem
    h = handle_response(Api::Client.new(params).redeem)

    flash[:success] = "Your previous balance was #{h['old_balance']} and now it is #{h['new_balance']}. I hope you enjoy your redeem!"
    redirect_to controller: 'dashboard', action: 'index', user: h['user']
  end

  private

  def handle_response(resp)
    JSON.parse(resp.body)['data'].first['attributes']
  end
end


