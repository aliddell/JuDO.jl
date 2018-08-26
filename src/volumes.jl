mutable struct Volume
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

struct VolumeSnapshot
    id::String
    name::String
    created_at::DateTime
    regions::Array{String, 1}
    resourceid::String
    resourcetype::String
    mindisksize::Real
    sizegigabytes::Real

    function VolumeSnapshot(data::Dict{String})
        data["created_at"] = DateTime(data["created_at"][1:end-1])

        new(
            data["id"],
            data["name"],
            data["created_at"],
            data["regions"],
            data["resource_id"],
            data["resource_type"],
            data["min_disk_size"],
            data["size_gigabytes"]
        )
    end
end

function show(io::IO, s::VolumeSnapshot)
    print(io, "$(s.name)")
end

# List all volumes
function getallvolumes!(client::AbstractClient; kwargs...)
    # check if a request for all volumes in a region
    if haskey(kwargs, "region")
        if isa(kwargs["region"], String)
            region = kwargs["region"]
        elseif isa(kwargs["region"], Region)
            region = kwargs["region"].slug
        else
            error("type not recognized for region: $(typeof(kwargs["region"]))")
        end
        query = "&region=$(region)"
    else
        query = ""
    end

    uri = joinpath(ENDPOINT, "volumes?per_page=$MAXOBJECTS$query")
    getalldata!(client, uri, Volume)
end

# Create a new volume
function createvolume!(client::AbstractClient; name::String, size_gigabytes::Integer, kwargs...)
    postbody = Dict{String, Any}("name" => name, "size_gigabytes" => size_gigabytes)
    merge!(postbody, Dict{String, Any}([String(k[1]) => k[2] for k in kwargs]))

    uri = joinpath(ENDPOINT, "volumes")
    Volume(postdata!(client, uri, postbody))
end

# Retrieve an existing volume
function getvolume!(client::AbstractClient, volumeid::String)
    uri = joinpath(ENDPOINT, "volumes", volumeid)
    Volume(getdata!(client, uri))
end

function getvolume!(client::AbstractClient, volume::Volume)
    getvolume!(client, volume.id)
end

# Retrieve an existing volume by name
function getvolume!(client::AbstractClient; name::String, region::Union{String, Region})
    if isa(region, Region)
        region = region.slug
    end

    uri = joinpath(ENDPOINT, "volumes?name=$(name)&region=$(region)")
    getalldata!(client, uri, Volume)[1]
end

# List snapshots for a volume
function getallvolumesnapshots!(client::AbstractClient, volumeid::String)
    uri = joinpath(ENDPOINT, "volumes", volumeid, "snapshots?per_page=$MAXOBJECTS")
    getalldata!(client, uri, VolumeSnapshot)
end

function getallvolumesnapshots!(client::AbstractClient, volume::Volume)
    getallvolumesnapshots!(client, volume.id)
end

# Create a snapshot from a volume
function snapshotvolume!(client::AbstractClient, volumeid::String; name::String, kwargs...)
    postbody = Dict{String, Any}("name" => name)
    merge!(postbody, Dict{String, Any}([String(k[1]) => k[2] for k in kwargs]))

    uri = joinpath(ENDPOINT, "volumes", volumeid, "snapshots")
    VolumeSnapshot(postdata!(client, uri, postbody))
end

# Delete a volume
function deletevolume!(client::AbstractClient, volumeid::String)
    uri = joinpath(ENDPOINT, "volumes", volumeid)
    deletedata!(client, uri)
end

function deletevolume!(client::AbstractClient, volume::Volume)
    deletevolume!(client, volume.id)
end

# Delete a volume by name
function deletevolume!(client::AbstractClient; name::String, region::String)
    uri = joinpath(ENDPOINT, "volumes?name=$(name)&region=$(region)")
    deletedata!(client, uri)
end

# Delete a volume snapshot
function deletevolumesnapshot!(client::AbstractClient, snapshotid::Integer)
    uri = joinpath(ENDPOINT, "snapshots", "$(snapshotid)")
    deletedata!(client, uri)
end

function deletevolumesnapshot!(client::AbstractClient, snapshot::VolumeSnapshot)
    deletedata!(client, snapshot.id)
end

# Attach a volume to a droplet
# Attach a volume to a droplet by name (provide volume_name in kwargs)
function attachvolume!(client::AbstractClient, volumeid::String; droplet_id::Integer, kwargs...)
    postbody = Dict{String, Any}("type" => "attach", "droplet_id" => droplet_id)
    merge!(postbody, Dict{String, Any}([String(k[1]) => k[2] for k in kwargs]))

    uri = joinpath(ENDPOINT, "volumes", volumeid, "actions")
    Action(postdata!(client, uri, postbody))
end

function attachvolume!(client::AbstractClient, volume::Volume; droplet_id::Integer, kwargs...)
    attachvolume!(client, volume.id; droplet_id=droplet_id, kwargs...)
end

# Remove a volume from a droplet
# Remove a volume from a droplet by name (provide volume_name in kwargs)
function removevolume!(client::AbstractClient, volumeid::String; droplet_id::Integer, kwargs...)
    postbody = Dict{String, Any}("type" => "detach", "droplet_id" => droplet_id)
    merge!(postbody, Dict{String, Any}([String(k[1]) => k[2] for k in kwargs]))

    uri = joinpath(ENDPOINT, "volumes", volumeid, "actions")
    Action(postdata!(client, uri, postbody))
end

function removevolume!(client::AbstractClient, volume::Volume; droplet_id::Integer, kwargs...)
    removevolume!(client, volume.id; droplet_id=droplet_id, kwargs...)
end

# Resize a volume
function resizevolume!(client::AbstractClient, volumeid::String; size_gigabytes::Integer, kwargs...)
    postbody = Dict{String, Any}("type" => "resize", "size_gigabytes" => size_gigabytes)
    merge!(postbody, Dict{String, Any}([String(k[1]) => k[2] for k in kwargs]))

    uri = joinpath(ENDPOINT, "volumes", volumeid, "actions")
    Action(postdata!(client, uri, postbody))
end

function resizevolume!(client::AbstractClient, volume::Volume; size_gigabytes::Integer, kwargs...)
    data = resizevolume!(client, volume.id; kwargs...)
    volume.size_gigabytes = size_gigabytes # update volume size while we're here
    Action(data)
end

# List all actions for a volume
function getallvolumeactions!(client::AbstractClient, volumeid::String)
    uri = joinpath(ENDPOINT, "volumes", volumeid, "actions?per_page=$MAXOBJECTS")
    getalldata!(client, uri, Action)
end

function getallvolumeactions!(client::AbstractClient, volume::Volume)
    getallvolumeactions!(client, volume.id)
end

# Retrieve an existing volume action
function getvolumeaction!(client::AbstractClient, volumeid::String, actionid::Integer)
    uri = joinpath(ENDPOINT, "volumes", volumeid, "actions", "$(actionid)")
    Action(getdata!(client, uri))
end

function getvolumeaction!(client::AbstractClient, volume::Volume, actionid::Integer)
    getvolumeaction!(client, volume.id, actionid)
end

function getvolumeaction!(client::AbstractClient, volumeid::String, action::Action)
    getvolumeaction!(client, volumeid, action.id)
end

function getvolumeaction!(client::AbstractClient, volume::Volume, action::Action)
    getvolumeaction!(client, volume.id, action.id)
end
