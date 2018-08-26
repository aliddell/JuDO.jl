struct Region
    slug::String
    name::String
    sizes::Array{String, 1}
    available::Union{Nothing, Bool}
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

function getallregions!(client::AbstractClient)
    response = getdata!(client, joinpath(ENDPOINT, "regions"))

    if floor(response.status/100) == 2 # OK
        body = parse(String(response.body))
        meta = body["meta"]
        links = body["links"]
        data = body["regions"]

        regions = Array{Region, 1}(UndefInitializer(), meta["total"])

        for (i, region) in enumerate(data)
            regions[i] = Region(region)
        end
    else
        error("Received error $(response.status)")
    end

    regions
end
