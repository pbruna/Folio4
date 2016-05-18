json.array! @companies do |company|
  json.id company.rut.gsub(/\./i, '')
  json.name company.name
end
