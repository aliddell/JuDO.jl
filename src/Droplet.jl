struct Network
    gateway::String
    ip_address::String
    netmask::String
    ntype::String
end

function show(io::IO, n::Network)
    print(io, "Network ($(n.ip_address))")
end

struct Kernel
    id::Integer
    name::String
    version::String
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
    created_at::String
    status::String
    backup_ids::Array{Integer, 1}
    snapshot_ids::Array{Integer, 1}
    features::Array{String, 1}
    region::Region
    image::Image
    size::Size
    size_slug::String
    networks #::Dict{String, Array{Network, 1}}
    kernel #::Kernel
    tags::Array{String, 1}
    volume_ids::Array{Integer, 1}
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
            droplets[i] = Droplet(
                droplet["id"],
                droplet["name"],
                droplet["memory"],
                droplet["vcpus"],
                droplet["disk"],
                droplet["locked"],
                droplet["created_at"],
                droplet["status"],
                droplet["backup_ids"],
                droplet["snapshot_ids"],
                droplet["features"],
                Region(
                    droplet["region"]["slug"],
                    droplet["region"]["name"],
                    droplet["region"]["sizes"],
                    droplet["region"]["available"],
                    droplet["region"]["features"]
                ),
                Image(
                    droplet["image"]["id"],
                    droplet["image"]["name"],
                    droplet["image"]["type"],
                    droplet["image"]["distribution"],
                    droplet["image"]["slug"],
                    droplet["image"]["public"],
                    droplet["image"]["regions"],
                    droplet["image"]["min_disk_size"],
                    droplet["image"]["size_gigabytes"],
                    droplet["image"]["created_at"]
                ),
                Size(
                    droplet["size"]["slug"],
                    droplet["size"]["available"],
                    droplet["size"]["transfer"],
                    droplet["size"]["price_monthly"],
                    droplet["size"]["price_hourly"],
                    droplet["size"]["memory"],
                    droplet["size"]["vcpus"],
                    droplet["size"]["disk"],
                    droplet["size"]["regions"]
                ),
                droplet["size_slug"],
                nothing, # TODO: add Networks here
                nothing, # TODO: add Kernel here
                droplet["tags"],
                droplet["volume_ids"]
            )
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
            kernels[i] = Kernel(
                kernel["id"],
                kernel["name"],
                kernel["version"]
            )
        end
    else
        error("Received error $(response.status)")
    end

    kernels
end

function get_all_kernels_for_droplet(manager::Manager, droplet::Droplet)
    get_all_kernels_for_droplet(manager, droplet.id)
end
