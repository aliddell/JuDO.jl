struct Image
    id::Integer
    name::String
    imagetype::String
    distribution::String
    slug::Union{Nothing, String}
    public::Bool
    regions::Array{String, 1}
    mindisksize::Integer
    sizegigabytes::Real
    created_at::DateTime

    function Image(data::Dict{String})
        # we assume all DO datetimes are in UTC
        data["created_at"] = DateTime(data["created_at"][1:end-1])

        new(
            data["id"],
            data["name"],
            data["type"],
            data["distribution"],
            data["slug"],
            data["public"],
            data["regions"],
            data["min_disk_size"],
            data["size_gigabytes"],
            data["created_at"]
        )
    end
end

function show(io::IO, i::Image)
    print(io, "Image ($(i.distribution) $(i.name))")
end

function getallimages!(client::AbstractClient)
    uri = joinpath(ENDPOINT, "images")
    data = getdata!(client, uri)
    images = Array{Image, 1}(UndefInitializer(), length(data))

    for (i, image) in enumerate(data)
        images[i] = Image(image)
    end
end
