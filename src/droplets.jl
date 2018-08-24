struct Network
    gateway::String
    ipaddress::String
    netmask::String
    networktype::String

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
    print(io, "Network ($(n.ipaddress))")
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
    created_at::DateTime
    status::String
    backupids::Array{Integer, 1}
    snapshotids::Array{Integer, 1}
    features::Array{String, 1}
    region::Region
    image::Image
    size::Size
    sizeslug::String
    networks::Dict{String, Array{Network, 1}}
    kernel::Union{Nothing, Kernel}
    nextbackupwindow::Union{Nothing, Dict{String, DateTime}}
    tags::Array{String, 1}
    volumeids::Array{Integer, 1}

    function Droplet(data::Dict{String})
        # we assume all DO datetimes are in UTC
        data["created_at"] = DateTime(data["created_at"][1:end-1])

        data["region"] = Region(data["region"])
        data["image"] = Image(data["image"])
        data["size"] = Size(data["size"])

        if haskey(data["networks"], "v4")
            networks = Array{Network, 1}(UndefInitializer(), length(data["networks"]["v4"]))
            for (j, network) in enumerate(data["networks"]["v4"])
                networks[j] = Network(network)
            end
            data["networks"]["v4"] = networks
        end
        if haskey(data["networks"], "v6")
            networks = Array{Network, 1}(UndefInitializer(), length(data["networks"]["v6"]))
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
            bst  = DateTime(data["next_backup_window"]["start"][1:end-1])
            bend = DateTime(data["next_backup_window"]["end"][1:end-1])
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

function getalldroplets!(client::AbstractClient)
    uri = joinpath(ENDPOINT, "droplets")
    data = getdata!(client, uri)
    droplets = Array{Droplet, 1}(UndefInitializer(), length(data))

    for (i, droplet) in enumerate(data)
        droplets[i] = Droplet(droplet)
    end

    droplets
end

function getdroplet!(client::AbstractClient, droplet_id::Integer)
    uri = joinpath(ENDPOINT, "droplets", "$(droplet_id)")
    Droplet(getdata!(client, uri))
end

function getdroplet!(client::AbstractClient, droplet::Droplet)
    getdroplet!(client, droplet.id)
end

function getdropletsbytag!(client::AbstractClient, tag::String)
    uri = joinpath(ENDPOINT, "droplets?tag_name=$(tag)&per_page=$MAXOBJECTS")
    data = getdata!(client, uri)
    droplets = Array{Droplet, 1}(UndefInitializer(), length(data))

    for (i, droplet) in enumerate(data)
        droplets[i] = Droplet(droplet)
    end

    droplets
end

function getalldropletkernels!(client::AbstractClient, droplet_id::Integer)
    uri = joinpath(ENDPOINT, "droplets", "$(droplet_id)", "kernels")
    data = getdata!(client, uri)
    kernels = Array{Kernel, 1}(UndefInitializer(), length(data))

    for (i, kernel) in enumerate(data)
        kernels[i] = Kernel(kernel)
    end

    kernels
end

function getalldropletkernels!(client::AbstractClient, droplet::Droplet)
    getalldropletkernels!(client, droplet.id)
end

function createdroplet!(client::AbstractClient; kwargs...)
    postbody = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(postbody, "name")
        error("'name' is a required argument")
    end

    if !haskey(postbody, "region")
        error("'region' is a required argument")
    elseif postbody["region"] isa Region
        postbody["region"] = postbody["region"].slug
    end

    if !haskey(postbody, "size")
        error("'size' is a required argument")
    elseif postbody["size"] isa Size
        postbody["size"] = postbody["size"].slug
    end

    if !haskey(postbody, "image")
        error("'image' is a required argument")
    elseif postbody["image"] isa Image
        if postbody["image"].slug.hasvalue
            postbody["image"] = postbody["image"].slug
        else
            postbody["image"] = postbody["image"].id
        end
    end

    uri = joinpath(ENDPOINT, "droplets")
    Droplet(postdata!(client, uri, postbody))
end

function deletedroplet!(client::AbstractClient, droplet_id::Integer)
    uri = joinpath(ENDPOINT, "droplets", "$(droplet_id)")
    deletedata!(client, uri)
end

function deletedroplet!(client::AbstractClient, droplet::Droplet)
    deletedroplet!(client, droplet.id)
end
