struct Image
    id::Integer
    name::String
    itype::String
    distribution::String
    slug::Nullable{String}
    public::Bool
    regions::Array{String, 1}
    min_disk_size::Integer
    size_gigabytes::Real
    created_at::Dates.DateTime

    function Image(data::Dict{String})
        # we assume all DO datetimes are in UTC
        data["created_at"] = Dates.DateTime(data["created_at"][1:end-1])

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

function get_all_images(manager::Manager)
    response = get_data(manager, joinpath(ENDPOINT, "images?per_page=200"))

    if response.status == 200 # OK
        body = JSON.parse(String(response.body))
        meta = body["meta"]
        links = body["links"]
        data = body["images"]

        images = Array{Image, 1}(meta["total"])

        for (i, image) in enumerate(data)
            images[i] = Image(image)
        end
    else
        error("Received error $(response.status)")
    end

    images
end
