require 'sinatra/base'

class FakeGdExpress < Sinatra::Base
  
  # Gdexpress uses a header nanmed AuthKey with the API Key
  AUTH_KEY = "123456"
  GDE_METHODS = {"FiscalStatus" => "fiscal_status",
                 "Tracking" => "tracking",
                 "RecoverPdf" => "recover_pdf",
                 "RecoverXml" => "recover_xml"
               }
  
  get '/api/Core.svc/Core/:method/:ambiente/:rut_emisor/:tipo_dete/:folio' do
    return access_denied unless authenticate(env)
    xml_response 200, params[:method], 28
  end

  private

  def authenticate(env)
    return true if env["HTTP_AUTHKEY"] == AUTH_KEY
    false
  end
  
  def access_denied
    content_type :xml
    status 200
    File.open(File.dirname(__FILE__) + '/fixtures/files/' + "access_denied.xml", 'rb').read
  end
  
  def xml_response(response_code, method, folio)
    content_type :xml
    status response_code
    file_name = "#{folio}_#{GDE_METHODS[method]}.xml"
    begin
      File.open(File.dirname(__FILE__) + '/fixtures/files/' + file_name, 'rb').read
    rescue Errno::ENOENT => e
      File.open(File.dirname(__FILE__) + '/fixtures/files/' + "not_found.xml", 'rb').read
    end
  end
end