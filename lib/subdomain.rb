class Subdomain
  def self.matches?(request)
    request.subdomain.present? && request.subdomain !~ /(www|app|folio|dev)/
  end
end