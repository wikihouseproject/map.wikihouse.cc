json.array!(@places) do |place|
  json.type 'Feature'

  json.properties do
    json.name place.name
    json.amenity place.class.to_s
    json.content render_place(place)
    json.icon place.icon
  end

  json.geometry do
    json.type "Point"
    json.coordinates place.safe_latlng.reverse
  end
end
