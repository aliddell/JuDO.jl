struct Volume
    id::String
    region::Region
    droplet_ids::Array{Integer,1}
    name::String
    description::String
    size_gigabytes::Real
    created_at::DateTime

    function Volume(data::Dict{String})
        data["region"] = Region(data["region"])

        # we assume all DO datetimes are in UTC
        data["created_at"] = DateTime(data["created_at"][1:end-1])

        new(
            data["id"],
            data["region"],
            data["droplet_ids"],
            data["name"],
            data["description"],
            data["size_gigabytes"],
            data["created_at"]
        )
    end
end

function show(io::IO, v::Volume)
    print(io, "Volume ($(v.name))")
end

function get_all_volumes(client::AbstractClient)
    uri = joinpath(ENDPOINT, "volumes?per_page=200")
    body = get_data(client, uri)

    meta = body["meta"]
    links = body["links"]
    data = body["volumes"]

    volumes = Array{Volume, 1}(UndefInitializer(), meta["total"])

    for (i, volume) in enumerate(data)
        volumes[i] = Volume(volume)
    end

    volumes
end

function create_volume(client::AbstractClient; kwargs...)
    post_body = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(post_body, "size_gigabytes")
        error("'size_gigabytes' is a required argument")
    end

    if !haskey(post_body, "name")
        error("'name' is a required argument")
    end

    uri = joinpath(ENDPOINT, "volumes")
    body = post_data(client, uri, post_body)

    data = body["volume"]
    volume = Volume(data)
end

function get_volume(client::AbstractClient, volume_id::String)
    uri = joinpath(ENDPOINT, "volumes", volume_id)
    body = get_data(client, uri)

    data = body["volume"]
    volume = Volume(data)
end

function get_volume(client::AbstractClient, volume::Volume)
    get_volume(client, volume.id)
end

function get_volume(client::AbstractClient, name::String, region_slug::String)
    uri = joinpath(ENDPOINT, "volumes?name=$(name)&region=$(region_slug)")
    body = get_data(client, uri)

    meta = body["meta"]
    links = body["links"]

    data = body["volumes"]
    volumes = Array{Volume, 1}(UndefInitializer(), meta["total"])

    for (i, volume) in enumerate(data)
        volumes[i] = Volume(volume)
    end

    volumes
end

function get_all_volume_snapshots(client::AbstractClient, volume_id::String)
    uri = joinpath(ENDPOINT, "volumes", volume_id, "snapshots?per_page=200")
    body = get_data(client, uri)

    meta = body["meta"]
    links = body["links"]

    data = body["snapshots"]
    snapshots = Array{Snapshot, 1}(UndefInitializer(), meta["total"])

    for (i, snapshot) in enumerate(data)
        snapshots[i] = Snapshot(snapshot)
    end

    snapshots
end

function get_all_volume_snapshots(client::AbstractClient, volume::Volume)
    get_all_volume_snapshots(client, volume.id)
end

function create_snapshot_from_volume(client::AbstractClient, volume_id::String;
                                     kwargs...)
    post_body = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(post_body, "name")
        error("'name' is a required argument")
    end

    uri = joinpath(ENDPOINT, "volumes", volume_id, "snapshots")
    body = post_data(client, uri, post_body)

    data = body["snapshot"]
    snapshot = Snapshot(data)
end

function delete_volume(client::AbstractClient, volume_id::String)
    uri = joinpath(ENDPOINT, "volumes", volume_id)
    delete_data(client, uri)
end

function delete_volume(client::AbstractClient, volume::Volume)
    delete_volume(client, volume.id)
end

function delete_volume(client::AbstractClient, volume_name::String, region_slug::String)
    uri = joinpath(ENDPOINT, "volumes?name=$(volume_name)&region=$(region_slug)")
    delete_data(client, uri)
end

function attach_volume(client::AbstractClient, volume_id::String; kwargs...)
    post_body = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(post_body, "droplet_id")
        error("'droplet_id' is a required argument")
    end

    post_body["type"] = "attach"

    uri = joinpath(ENDPOINT, "volumes", volume_id, "actions")
    body = post_data(client, uri, post_body)

    data = body["action"]
    action = Action(data)
end

function attach_volume(client::AbstractClient, volume::Volume; kwargs...)
    attach_volume(client, volume.id; kwargs...)
end

function attach_volume(client::AbstractClient; kwargs...)
    post_body = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(post_body, "droplet_id")
        error("'droplet_id' is a required argument")
    end

    if !haskey(post_body, "volume_name")
        error("'volume_name' is a required argument")
    end

    post_body["type"] = "attach"

    uri = joinpath(ENDPOINT, "volumes", "actions")
    body = post_data(client, uri, post_body)

    data = body["action"]
    action = Action(data)
end

function remove_volume(client::AbstractClient, volume_id::String; kwargs...)
    post_body = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(post_body, "droplet_id")
        error("'droplet_id' is a required argument")
    end

    post_body["type"] = "detach"

    uri = joinpath(ENDPOINT, "volumes", volume_id, "actions")
    body = post_data(client, uri, post_body)

    data = body["action"]
    action = Action(data)
end

function remove_volume(client::AbstractClient, volume::Volume; kwargs...)
    remove_volume(client, volume.id; kwargs...)
end

function remove_volume(client::AbstractClient; kwargs...)
    post_body = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(post_body, "droplet_id")
        error("'droplet_id' is a required argument")
    end

    if !haskey(post_body, "volume_name")
        error("'volume_name' is a required argument")
    end

    post_body["type"] = "detach"

    uri = joinpath(ENDPOINT, "volumes", "actions")
    body = post_data(client, uri, post_body)

    data = body["action"]
    action = Action(data)
end

function resize_volume(client::AbstractClient, volume_id::String; kwargs...)
    post_body = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(post_body, "size_gigabytes")
        error("'size_gigabytes' is a required argument")
    end

    post_body["type"] = "resize"

    uri = joinpath(ENDPOINT, "volumes", volume_id, "actions")
    body = post_data(client, uri, post_body)

    data = body["action"]
    action = Action(data)
end

function resize_volume(client::AbstractClient, volume::Volume; kwargs...)
    resize_volume(client, volume.id; kwargs...)
end

function get_all_volume_actions(client::AbstractClient, volume_id::String)
    uri = joinpath(ENDPOINT, "volumes", volume_id, "actions?per_page=200")
    body = get_data(client, uri)

    meta = body["meta"]
    links = body["links"]

    data = body["actions"]
    actions = Array{Action, 1}(UndefInitializer(), meta["total"])

    for (i, action) in enumerate(data)
        actions[i] = Action(action)
    end

    actions
end

function get_all_volume_actions(client::AbstractClient, volume::Volume)
    get_all_volume_actions(client, volume.id)
end

function get_volume_action(client::AbstractClient, volume_id::String,
                           action_id::Integer)
    uri = joinpath(ENDPOINT, "volumes", volume_id, "actions",
                   "$(action_id)")
    body = get_data(client, uri)

    data = body["action"]
    action = Action(data)
end

function get_volume_action(client::AbstractClient, volume::Volume,
                           action_id::Integer)
    get_volume_action(client, volume.id, action_id)
end

function get_volume_action(client::AbstractClient, volume_id::String,
                           action::Action)
    get_volume_action(client, volume_id, action.id)
end

function get_volume_action(client::AbstractClient, volume::Volume,
                           action::Action)
    get_volume_action(client, volume.id, action.id)
end
