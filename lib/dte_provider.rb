module DteProvider
  class << self

    def test
      puts "test"
    end

    def emit(dte)
      
    end
    
    def emited?(dte)
      
    end
    
    def process(dte, callback)
      hash = {processed: true, pdf_url: "http://masev.folio4.dev/OC-FACH-29-671-SE14.pdf"}
      return dte.send(callback, hash)
    end

  end  
end