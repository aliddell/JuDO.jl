struct Action
    id::Integer
    status::String
    actiontype::String
    started_at::DateTime
    completed_at::Union{Nothing, DateTime}
    resourceid::Union{Nothing, Integer}
    resourcetype::String
    region::Union{Nothing, Region}
    regionslug::Union{Nothing, String}

    function Action(data::Dict{String})
        data["started_at"] = DateTime(data["started_at"][1:end-1])
        if data["completed_at"] != nothing
            data["completed_at"] = DateTime(data["completed_at"][1:end-1])
        end
        if data["region"] != nothing
            data["region"] = Region(data["region"])
        end

        new(
            data["id"],
            data["status"],
            data["type"],
            data["started_at"],
            data["completed_at"],
            data["resource_id"],
            data["resource_type"],
            data["region"],
            data["region_slug"]
        )
    end
end

function show(io::IO, a::Action)
    print(io, "Action ($(a.actiontype), $(a.started_at))")
end

# List all actions
function getallactions!(client::AbstractClient)
    uri = joinpath(ENDPOINT, "actions?per_page=$MAXOBJECTS")
    getalldata!(client, uri, Action)
end

# Retrieve an existing action
function getaction!(client::AbstractClient, action_id::Integer)
    uri = joinpath(ENDPOINT, "actions", "$(action_id)")
    Action(getdata!(client, uri))
end

function getaction!(client::AbstractClient, action::Action)
    getaction!(client, action.name)
end
