class MoneyAccountType < OpenStruct
  
  def initialize(id, name, credit = false)
    @id = id
    @name = name
    @credit = credit
  end
  
  def credit?
    credit
  end
  
end