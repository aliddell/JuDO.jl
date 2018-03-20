struct Network
    gateway::String
    ip_address::String
    netmask::String
    ntype::String

    function Network(data::Dict{String, Any})
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

    function Kernel(data::Dict{String, Any})
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

    function Droplet(data::Dict{String, Any})
        # we assume all DO datetimes are in UTC
        data["created_at"] = Dates.DateTime(data["created_at"][1:end-1])

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
            Region(data["region"]),
            Image(data["image"]),
            Size(data["size"]),
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

function get_all_droplets(manager::Manager)
    response = get_data(manager, joinpath(ENDPOINT, "droplets?per_page=200"))

    if response.status == 200 # OK
        body = JSON.parse(String(response.body))
        meta = body["meta"]
        links = body["links"]
        data = body["droplets"]

        droplets = Array{Droplet, 1}(meta["total"])

        for (i, droplet) in enumerate(data)
            droplets[i] = Droplet(droplet)
        end
    else
        error("Received error $(response.status)")
    end

    droplets
end

function get_droplet(manager::Manager, droplet_id::Integer)
    response = get_data(manager, joinpath(ENDPOINT, "droplets", "$(droplet_id)"))

    if response.status == 200 # OK
        body = JSON.parse(String(response.body))
        data = body["droplet"]

        droplet = Droplet(data)
    else
        error("Received error $(response.status)")
    end
end

function get_droplet(manager::Manager, droplet::Droplet)
    get_droplet(manager, droplet.id)
end

function get_droplets_by_tag(manager::Manager, tag::String)
    response = get_data(manager, joinpath(ENDPOINT, "droplets?tag_name=$(tag)&per_page=200"))

    if response.status == 200 # OK
        body = JSON.parse(String(response.body))
        meta = body["meta"]
        links = body["links"]
        data = body["droplets"]

        droplets = Array{Droplet, 1}(meta["total"])

        for (i, droplet) in enumerate(data)
            droplets[i] = Droplet(droplet)
        end
    else
        error("Received error $(response.status)")
    end

    droplets
end

function get_all_kernels_for_droplet(manager::Manager, droplet_id::Integer)
    response = get_data(manager, joinpath(ENDPOINT, "droplets", "$(droplet_id)", "kernels?per_page=200"))

    if response.status == 200 # OK
        body = JSON.parse(String(response.body))
        meta = body["meta"]
        links = body["links"]
        data = body["kernels"]

        kernels = Array{Kernel, 1}(meta["total"])

        for (i, kernel) in enumerate(data)
            kernels[i] = Kernel(kernel)
        end
    else
        error("Received error $(response.status)")
    end

    kernels
end

function get_all_kernels_for_droplet(manager::Manager, droplet::Droplet)
    get_all_kernels_for_droplet(manager, droplet.id)
end

function create_droplet(manager::Manager; kwargs...)
    body = Dict([String(k[1]) => k[2] for k in kwargs])

    if !("name" in keys(body))
        error("'name' is a required argument")
    end

    if !("region" in keys(body))
        error("'region' is a required argument")
    elseif body["region"] isa Region
        body["region"] = body["region"].slug
    end

    if !("size" in keys(body))
        error("'size' is a required argument")
    elseif body["size"] isa Size
        body["size"] = body["size"].slug
    end

    if !("image" in keys(body))
        error("'image' is a required argument")
    elseif body["image"] isa Image
        if body["image"].slug != nothing
            body["image"] = body["image"].slug
        else
            body["image"] = body["image"].id
        end
    end

    response = post_data(manager, joinpath(ENDPOINT, "droplets"), body)

    if response.status == 202 # OK
        body = JSON.parse(String(response.body))
        data = body["droplet"]

        droplet = Droplet(data)
    else
        error("Received error $(response.status)")
    end
end

function delete_droplet(manager::Manager, droplet_id::Integer)
    delete_data(manager, joinpath(ENDPOINT, "droplets", "$(droplet_id)"))
end

function delete_droplet(manager::Manager, droplet::Droplet)
    delete_droplet(manager, droplet.id)
end
