struct Snapshot
    id::String
    name::String
    created_at::DateTime
    regions::Array{String, 1}
    resourceid::String
    resourcetype::String
    min_disk_size::Real
    sizegigabytes::Real

    function Snapshot(data::Dict{String})
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

function show(io::IO, s::Snapshot)
    print(io, "$(s.name)")
end

# Delete a (volume or droplet) snapshot
function deletesnapshot!(client::AbstractClient, snapshotid::Integer)
    uri = joinpath(ENDPOINT, "snapshots", "$(snapshotid)")
    deletedata!(client, uri)
end

function deletesnapshot!(client::AbstractClient, snapshot::Snapshot)
    deletedata!(client, snapshot.id)
end
