struct Region
    slug::String
    name::String
    sizes::Array{String, 1}
    available::Bool
    features::Array{String, 1}

    function Region(data::Dict{String})
        new(
            data["slug"],
            data["name"],
            data["sizes"],
            data["available"],
            data["features"]
        )
    end
end

function show(io::IO, r::Region)
    print(io, "Region ($(r.name))")
end

function get_all_regions(manager::Manager)
    response = get_data(manager, joinpath(ENDPOINT, "regions?per_page=200"))

    if response.status == 200 # OK
        body = JSON.parse(String(response.body))
        meta = body["meta"]
        links = body["links"]
        data = body["regions"]

        regions = Array{Region, 1}(meta["total"])

        for (i, region) in enumerate(data)
            regions[i] = Region(region)
        end
    else
        error("Received error $(response.status)")
    end

    regions
end
