class Upgrade < ApplicationRecord
	validates :name, presence: true
	validates :price, presence: true, numericality: { :greater_than_or_equal_to => 0.99 }
	validates :wepay_access_token, presence: true
	validates :wepay_account_id, presence: true


	# creates a checkout object using WePay API for this user
  def create_checkout(redirect_uri)
    app_fee = self.price * 0.021

    params = {
      :account_id => self.wepay_account_id,
      :short_description => "#{self.name} boost from Tradies!",
      :type => :service,
      # :auto_release => false,
      :currency => 'USD',
      :amount => self.price,      
      :fee => {
          :fee_payer => 'payee'
      },
      :hosted_checkout => {
          :mode  => 'iframe',
          :redirect_uri => redirect_uri
      }
    }
    response = WEPAY.call('/checkout/create', self.wepay_access_token, params)

    if !response
      raise "Error - no response from WePay"
    elsif response['error']
      raise "Error - " + response["error_description"]
    end
    # puts response
    return response
  end
end
