class Plan < ActiveRecord::Base
  
  def self.trial
    where(:name => "trial").first
  end
  
end
