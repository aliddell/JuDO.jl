struct Size
    slug::String
    available::Bool
    transfer::Real
    price_monthly::Real
    price_hourly::Real
    memory::Integer
    vcpus::Integer
    disk::Integer
    regions::Array{String, 1}

    function Size(data::Dict{String})
        new(
            data["slug"],
            data["available"],
            data["transfer"],
            data["price_monthly"],
            data["price_hourly"],
            data["memory"],
            data["vcpus"],
            data["disk"],
            data["regions"]
        )
    end
end

function show(io::IO, s::Size)
    print(io, "Size ($(s.slug))")
end

function get_all_sizes(client::AbstractClient)
    response = get_data(client, joinpath(ENDPOINT, "sizes?per_page=200"))

    if floor(response.status/100) == 2 # OK
        body = JSON.parse(String(response.body))
        meta = body["meta"]
        links = body["links"]
        data = body["sizes"]

        sizes = Array{Size, 1}(meta["total"])

        for (i, dsize) in enumerate(data)
            sizes[i] = Size(dsize)
        end
    else
        error("Received error $(response.status)")
    end

    sizes
end
