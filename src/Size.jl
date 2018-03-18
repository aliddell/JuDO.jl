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
end

function show(io::IO, s::Size)
    print(io, "Size ($(s.slug))")
end

function get_all_sizes(manager::Manager)
    response = get_data(manager, joinpath(ENDPOINT, "sizes?per_page=200"))

    if response.status == 200 # OK
        body = JSON.parse(String(response.body))
        meta = body["meta"]
        links = body["links"]
        data = body["sizes"]

        sizes = Array{Size, 1}(meta["total"])

        for (i, dsize) in enumerate(data)
            sizes[i] = Size(
                dsize["slug"],
                dsize["available"],
                dsize["transfer"],
                dsize["price_monthly"],
                dsize["price_hourly"],
                dsize["memory"],
                dsize["vcpus"],
                dsize["disk"],
                dsize["regions"]
            )
        end
    else
        error("Received error $(response.status)")
    end

    sizes
end
