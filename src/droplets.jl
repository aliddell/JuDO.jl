struct Network
    gateway::String
    ip_address::String
    netmask::String
    ntype::String

    function Network(data::Dict{String})
        new(
            data["gateway"],
            data["ip_address"],
            "$(data["netmask"])", # ipv6 netmasks are integers
            data["type"]
        )
    end
end

function show(io::IO, n::Network)
    print(io, "Network ($(n.ip_address))")
end

struct Kernel
    id::Integer
    name::String
    version::String

    function Kernel(data::Dict{String})
        new(
            data["id"],
            data["name"],
            data["version"]
        )
    end
end

function show(io::IO, k::Kernel)
    print(io, "Kernel ($(k.name)-$(k.version))")
end

struct Droplet
    id::Integer
    name::String
    memory::Integer
    vcpus::Integer
    disk::Integer
    locked::Bool
    created_at::Dates.DateTime
    status::String
    backup_ids::Array{Integer, 1}
    snapshot_ids::Array{Integer, 1}
    features::Array{String, 1}
    region::Region
    image::Image
    size::Size
    size_slug::String
    networks::Dict{String, Array{Network, 1}}
    kernel::Nullable{Kernel}
    next_backup_window::Nullable{Dict{String, Dates.DateTime}}
    tags::Array{String, 1}
    volume_ids::Array{Integer, 1}

    function Droplet(data::Dict{String})
        # we assume all DO datetimes are in UTC
        data["created_at"] = Dates.DateTime(data["created_at"][1:end-1])

        data["region"] = Region(data["region"])
        data["image"] = Image(data["image"])
        data["size"] = Size(data["size"])

        if "v4" in keys(data["networks"])
            networks = Array{Network, 1}(length(data["networks"]["v4"]))
            for (j, network) in enumerate(data["networks"]["v4"])
                networks[j] = Network(network)
            end
            data["networks"]["v4"] = networks
        end
        if "v6" in keys(data["networks"])
            networks = Array{Network, 1}(length(data["networks"]["v6"]))
            for (j, network) in enumerate(data["networks"]["v6"])
                networks[j] = Network(network)
            end
            data["networks"]["v6"] = networks
        end

        if data["kernel"] != nothing
            data["kernel"] = Kernel(data["kernel"])
        end

        if data["next_backup_window"] != nothing
            # we assume all DO datetimes are in UTC
            bst  = Dates.DateTime(data["next_backup_window"]["start"][1:end-1])
            bend = Dates.DateTime(data["next_backup_window"]["end"][1:end-1])
            data["next_backup_window"] = Dict("start" => bst,
                                              "end" => bend)
        end

        new(
            data["id"],
            data["name"],
            data["memory"],
            data["vcpus"],
            data["disk"],
            data["locked"],
            data["created_at"],
            data["status"],
            data["backup_ids"],
            data["snapshot_ids"],
            data["features"],
            data["region"],
            data["image"],
            data["size"],
            data["size_slug"],
            data["networks"],
            data["kernel"],
            data["next_backup_window"],
            data["tags"],
            data["volume_ids"]
        )
    end
end

function show(io::IO, d::Droplet)
    print(io, "Droplet ($(d.name))")
end

function get_all_droplets(client::AbstractClient)
    uri = joinpath(ENDPOINT, "droplets?per_page=200")
    body = get_data(client, uri)

    meta = body["meta"]
    links = body["links"]
    data = body["droplets"]

    droplets = Array{Droplet, 1}(meta["total"])

    for (i, droplet) in enumerate(data)
        droplets[i] = Droplet(droplet)
    end

    droplets
end

function get_droplet(client::AbstractClient, droplet_id::Integer)
    uri = joinpath(ENDPOINT, "droplets", "$(droplet_id)")
    body = get_data(client, uri)

    data = body["droplet"]
    droplet = Droplet(data)
end

function get_droplet(client::AbstractClient, droplet::Droplet)
    get_droplet(client, droplet.id)
end

function get_droplets_by_tag(client::AbstractClient, tag::String)
    uri = joinpath(ENDPOINT, "droplets?tag_name=$(tag)&per_page=200")
    body = get_data(client, uri)

    meta = body["meta"]
    links = body["links"]
    data = body["droplets"]

    droplets = Array{Droplet, 1}(meta["total"])

    for (i, droplet) in enumerate(data)
        droplets[i] = Droplet(droplet)
    end

    droplets
end

function get_all_droplet_kernels(client::AbstractClient, droplet_id::Integer)
    uri = joinpath(ENDPOINT, "droplets", "$(droplet_id)", "kernels?per_page=200")
    body = get_data(client, uri)

    meta = body["meta"]
    links = body["links"]
    data = body["kernels"]

    kernels = Array{Kernel, 1}(meta["total"])

    for (i, kernel) in enumerate(data)
        kernels[i] = Kernel(kernel)
    end

    kernels
end

function get_all_droplet_kernels(client::AbstractClient, droplet::Droplet)
    get_all_droplet_kernels(client, droplet.id)
end

function create_droplet(client::AbstractClient; kwargs...)
    post_body = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !("name" in keys(post_body))
        error("'name' is a required argument")
    end

    if !("region" in keys(post_body))
        error("'region' is a required argument")
    elseif post_body["region"] isa Region
        post_body["region"] = post_body["region"].slug
    end

    if !("size" in keys(post_body))
        error("'size' is a required argument")
    elseif post_body["size"] isa Size
        post_body["size"] = post_body["size"].slug
    end

    if !("image" in keys(post_body))
        error("'image' is a required argument")
    elseif post_body["image"] isa Image
        if post_body["image"].slug.hasvalue
            post_body["image"] = post_body["image"].slug
        else
            post_body["image"] = post_body["image"].id
        end
    end

    uri = joinpath(ENDPOINT, "droplets")
    body = post_data(client, uri, post_body)

    data = body["droplet"]
    droplet = Droplet(data)
end

function delete_droplet(client::AbstractClient, droplet_id::Integer)
    uri = joinpath(ENDPOINT, "droplets", "$(droplet_id)")
    delete_data(client, uri)
end

function delete_droplet(client::AbstractClient, droplet::Droplet)
    delete_droplet(client, droplet.id)
end
