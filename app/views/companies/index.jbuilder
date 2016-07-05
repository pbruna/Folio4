json.array! @companies do |company|
  json.id company.rut.gsub(/\./i, '')
  json.internalId company.id
  json.name company.name
end
