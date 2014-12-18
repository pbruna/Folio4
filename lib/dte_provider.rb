module DteProvider
  class << self

    def pdf_base64(dte)
      gde_client = gd_express_client
      gde_client.recover_pdf_base64 dte
    end
    
    def check_dte_status(dte, callback)
      result = { processed: false }
      gde_client = gd_express_client
      if gde_client.processed?(dte)
        result[:processed] = true
        result[:accepted] = gde_client.accepted?(dte)
        result[:log] = gde_client.fiscal_status(dte)[:data] unless result[:accepted]
      end
      dte.send callback, result
    end
    
    private
    def gd_express_client
      config = Rails.configuration.gdexpress
      gd_client = Gdexpress::Client.new(
            api_token: config[:api_token],
            dte_box: config[:dte_box],
            environment: config[:environment].to_sym
          )
      gd_client
    end

  end  
end