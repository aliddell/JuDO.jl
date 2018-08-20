struct Snapshot
    id::String
    name::String
    created_at::DateTime
    regions::Array{String, 1}
    resource_id::String
    resource_type::String
    min_disk_size::Real
    size_gigabytes::Real

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

function delete_snapshot(client::AbstractClient, snapshot_id::Integer)
    uri = joinpath(ENDPOINT, "snapshots", "$(snapshot_id)")
    delete_data(client, uri)
end

function delete_snapshot(client::AbstractClient, snapshot::Snapshot)
    delete_data(client, snapshot.id)
end
