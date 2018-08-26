struct Network
    gateway::String
    ipaddress::String
    netmask::Union{String, Integer}  # ipv6 netmasks are integers
    networktype::String

    function Network(data::Dict{String})
        new(
            data["gateway"],
            data["ip_address"],
            data["netmask"],
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
    region::Union{Nothing, Region}
    image::Union{Nothing, Image}
    size::Union{Nothing, Size}
    sizeslug::String
    networks::Dict{String, Array{Network, 1}}
    kernel::Union{Nothing, Kernel}
    nextbackupwindow::Union{Nothing, Dict{String, DateTime}}
    tags::Array{String, 1}
    volumeids::Array{Integer, 1}

    function Droplet(data::Dict{String})
        # we assume all DO datetimes are in UTC
        data["created_at"] = DateTime(data["created_at"][1:end-1])

        if isempty(data["region"])
            data["region"] = nothing
        else
            data["region"] = Region(data["region"])
        end
        if isempty(data["image"])
            data["image"] = nothing
        else
            data["image"] = Image(data["image"])
        end
        if isempty(data["size"])
            data["size"] = nothing
        else
            data["size"] = Size(data["size"])
        end

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
        if !haskey(data, "next_backup_window")
            data["next_backup_window"] = nothing
        end
        if data["next_backup_window"] != nothing
            # we assume all DO datetimes are in UTC
            bst  = DateTime(data["next_backup_window"]["start"][1:end-1])
            bend = DateTime(data["next_backup_window"]["end"][1:end-1])
            data["next_backup_window"] = Dict("start" => bst, "end" => bend)
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

struct DropletSnapshot
    id::Integer
    name::String
    snapshottype::String
    distribution::String
    slug::Union{Nothing, String}
    public::Bool
    regions::Array{String, 1}
    mindisksize::Integer
    created_at::DateTime

    function DropletSnapshot(data::Dict{String})
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
            data["created_at"]
        )
    end
end

function show(io::IO, d::DropletSnapshot)
    print(io, "Snapshot ($(d.name))")
end

# List all droplets
function getalldroplets!(client::AbstractClient)
    uri = joinpath(ENDPOINT, "droplets?per_page=$MAXOBJECTS")
    getalldata!(client, uri, Droplet)
end

# List droplets by tag
function getdropletsbytag!(client::AbstractClient; tag::String)
    uri = joinpath(ENDPOINT, "droplets?tag_name=$(tag)&per_page=$MAXOBJECTS")
    getalldata!(client, uri, Droplet)
end

# Retrieve an existing droplet by ID
function getdroplet!(client::AbstractClient, droplet_id::Integer)
    uri = joinpath(ENDPOINT, "droplets", "$(droplet_id)")
    Droplet(getdata!(client, uri))
end

function getdroplet!(client::AbstractClient, droplet::Droplet)
    getdroplet!(client, droplet.id)
end

# List all available kernels for a droplet
function getalldropletkernels!(client::AbstractClient, dropletid::Integer)
    uri = joinpath(ENDPOINT, "droplets", "$(dropletid)", "kernels")
    getalldata!(client, uri, Kernel)
end

function getalldropletkernels!(client::AbstractClient, droplet::Droplet)
    getalldropletkernels!(client, droplet.id)
end

# Create a new droplet
function createdroplet!(client::AbstractClient; name::String, region::Union{Region, String},
                        size::String, image::String, kwargs...)
    if isa(region, Region)
        region = region.slug
    end
    if isa(size, Size)
        size = size.slug
    end
    if isa(image, Image)
        if image.slug != nothing
            image = image.slug
        else
            image = image.id
        end
    end

    postbody = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])
    merge!(postbody, Dict{String, Any}("region" => region, "size" => size, "image" => image))

    uri = joinpath(ENDPOINT, "droplets")
    Droplet(postdata!(client, uri, postbody))
end

# Create multiple droplets
function createdroplets!(client::AbstractClient; names::Array{String}, region::Union{Region, String},
                        size::String, image::String, kwargs...)
    if isa(region, Region)
        region = region.slug
    end
    if isa(size, Size)
        size = size.slug
    end
    if isa(image, Image)
        if image.slug != nothing
            image = image.slug
        else
            image = image.id
        end
    end

    postbody = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])
    merge!(postbody, Dict{String, Any}("region" => region, "size" => size, "image" => image))

    uri = joinpath(ENDPOINT, "droplets")
    Droplet(postdata!(client, uri, postbody))
end

# List snapshots for a droplet
function getalldropletsnapshots!(client::AbstractClient, dropletid::Integer)
    uri = joinpath(ENDPOINT, "droplets", "$dropletid", "snapshots?per_page=$MAXOBJECTS")
    getalldata!(client, uri, DropletSnapshot)
end

function getalldropletsnapshots!(client::AbstractClient, droplet::Droplet)
    getalldropletsnapshots!(client, droplet.id)
end

function deletedroplet!(client::AbstractClient, droplet_id::Integer)
    uri = joinpath(ENDPOINT, "droplets", "$(droplet_id)")
    deletedata!(client, uri)
end

function deletedroplet!(client::AbstractClient, droplet::Droplet)
    deletedroplet!(client, droplet.id)
end
