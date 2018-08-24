struct Volume
    id::String
    region::Region
    droplet_ids::Array{Integer,1}
    name::String
    description::String
    sizegigabytes::Real
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

function getallvolumes!(client::AbstractClient)
    uri = joinpath(ENDPOINT, "volumes?per_page=$MAXOBJECTS")
    data = getdata!(client, uri)

    volumes = Array{Volume, 1}(UndefInitializer(), length(data))

    for (i, volume) in enumerate(data)
        volumes[i] = Volume(volume)
    end

    volumes
end

function createvolume!(client::AbstractClient; kwargs...)
    postbody = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(postbody, "size_gigabytes")
        error("'sizegigabytes' is a required argument")
    end

    if !haskey(postbody, "name")
        error("'name' is a required argument")
    end

    uri = joinpath(ENDPOINT, "volumes")
    Volume(postdata!(client, uri, postbody))
end

function getvolume!(client::AbstractClient, volume_id::String)
    uri = joinpath(ENDPOINT, "volumes", volume_id)
    Volume(getdata!(client, uri))
end

function getvolume!(client::AbstractClient, volume::Volume)
    getvolume!(client, volume.id)
end

function getvolume!(client::AbstractClient; name::String, regionslug::String)
    uri = joinpath(ENDPOINT, "volumes?name=$(name)&region=$(regionslug)")
    data = getdata!(client, uri)
    volumes = Array{Volume, 1}(UndefInitializer(), length(data))

    for (i, volume) in enumerate(data)
        volumes[i] = Volume(volume)
    end

    volumes
end

function getallvolumesnapshots!(client::AbstractClient, volume_id::String)
    uri = joinpath(ENDPOINT, "volumes", volume_id, "snapshots?per_page=$MAXOBJECTS")
    data = getdata!(client, uri)
    snapshots = Array{Snapshot, 1}(UndefInitializer(), length(data))

    for (i, snapshot) in enumerate(data)
        snapshots[i] = Snapshot(snapshot)
    end

    snapshots
end

function getallvolumesnapshots!(client::AbstractClient, volume::Volume)
    getallvolumesnapshots!(client, volume.id)
end

function snapshotvolume!(client::AbstractClient, volume_id::String;
                                     kwargs...)
    postbody = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(postbody, "name")
        error("'name' is a required argument")
    end

    uri = joinpath(ENDPOINT, "volumes", volume_id, "snapshots")
    Snapshot(postdata!(client, uri, postbody))
end

function deletevolume!(client::AbstractClient, volume_id::String)
    uri = joinpath(ENDPOINT, "volumes", volume_id)
    deletedata!(client, uri)
end

function deletevolume!(client::AbstractClient, volume::Volume)
    deletevolume!(client, volume.id)
end

function deletevolume!(client::AbstractClient, volume_name::String, regionslug::String)
    uri = joinpath(ENDPOINT, "volumes?name=$(volume_name)&region=$(regionslug)")
    deletedata!(client, uri)
end

function attachvolume!(client::AbstractClient, volume_id::String; kwargs...)
    postbody = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(postbody, "droplet_id")
        error("'droplet_id' is a required argument")
    end

    postbody["type"] = "attach"

    uri = joinpath(ENDPOINT, "volumes", volume_id, "actions")
    Action(postdata!(client, uri, postbody))
end

function attachvolume!(client::AbstractClient, volume::Volume; kwargs...)
    attachvolume!(client, volume.id; kwargs...)
end

function attachvolume!(client::AbstractClient; kwargs...)
    postbody = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(postbody, "droplet_id")
        error("'droplet_id' is a required argument")
    end

    if !haskey(postbody, "volume_name")
        error("'volume_name' is a required argument")
    end

    postbody["type"] = "attach"

    uri = joinpath(ENDPOINT, "volumes", "actions")
    Action(postdata!(client, uri, postbody))
end

function removevolume!(client::AbstractClient, volume_id::String; kwargs...)
    postbody = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(postbody, "droplet_id")
        error("'droplet_id' is a required argument")
    end

    postbody["type"] = "detach"

    uri = joinpath(ENDPOINT, "volumes", volume_id, "actions")
    Action(postdata!(client, uri, postbody))
end

function removevolume!(client::AbstractClient, volume::Volume; kwargs...)
    removevolume!(client, volume.id; kwargs...)
end

function removevolume!(client::AbstractClient; kwargs...)
    postbody = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(postbody, "droplet_id")
        error("'droplet_id' is a required argument")
    end

    if !haskey(postbody, "volume_name")
        error("'volume_name' is a required argument")
    end

    postbody["type"] = "detach"

    uri = joinpath(ENDPOINT, "volumes", "actions")
    Action(postdata!(client, uri, postbody))
end

function resizevolume!(client::AbstractClient, volume_id::String; kwargs...)
    postbody = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(postbody, "size_gigabytes")
        error("'sizegigabytes' is a required argument")
    end

    postbody["type"] = "resize"

    uri = joinpath(ENDPOINT, "volumes", volume_id, "actions")
    Action(postdata!(client, uri, postbody))
end

function resizevolume!(client::AbstractClient, volume::Volume; kwargs...)
    resizevolume!(client, volume.id; kwargs...)
end

function getallvolumeactions!(client::AbstractClient, volume_id::String)
    uri = joinpath(ENDPOINT, "volumes", volume_id, "actions?per_page=$MAXOBJECTS")
    data = getdata!(client, uri)
    actions = Array{Action, 1}(UndefInitializer(), length(data))

    for (i, action) in enumerate(data)
        actions[i] = Action(action)
    end

    actions
end

function getallvolumeactions!(client::AbstractClient, volume::Volume)
    getallvolumeactions!(client, volume.id)
end

function getvolumeaction!(client::AbstractClient, volume_id::String,
                           action_id::Integer)
    uri = joinpath(ENDPOINT, "volumes", volume_id, "actions",
                   "$(action_id)")
    Action(getdata!(client, uri))
end

function getvolumeaction!(client::AbstractClient, volume::Volume,
                           action_id::Integer)
    getvolumeaction!(client, volume.id, action_id)
end

function getvolumeaction!(client::AbstractClient, volume_id::String,
                           action::Action)
    getvolumeaction!(client, volume_id, action.id)
end

function getvolumeaction!(client::AbstractClient, volume::Volume,
                           action::Action)
    getvolumeaction!(client, volume.id, action.id)
end
