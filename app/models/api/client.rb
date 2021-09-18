class Api::Client
  def initialize(params)
    @conn = Faraday.new(
      url: ENV['API_URL'],
      headers: {
        'Accept' => 'application/vnd.fidor.de',
        'Content-Type' => 'application/vnd.api+json'
      }
    )
    @params = encode params
    @bonus_id = params[:bonus_id]
  end

  def redeem
    update("#{@bonus_id}/redeem")
  end

  def grant
    update("#{@bonus_id}/grant")
  end

  def update(path)
    resp = @conn.put(path) do |req|
      req.body = @params.to_json
    end
  end

  private

  def encode(params)
    {
      "data": {
        "type": "bonus",
        "attributes": {
          "user_uid": params[:user],
          "amount": params[:amount]
        }
      }
    }
  end
end
