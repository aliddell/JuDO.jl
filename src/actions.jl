struct Action
    id::Integer
    status::String
    action_type::String
    started_at::Dates.DateTime
    completed_at::Nullable{Dates.DateTime}
    resource_id::Integer
    resource_type::String
    region::Nullable{Region}
    region_slug::Nullable{String}

    function Action(data::Dict{String})
        data["started_at"] = Dates.DateTime(data["started_at"][1:end-1])
        if data["completed_at"] != nothing
            data["completed_at"] = Dates.DateTime(data["completed_at"][1:end-1])
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
    print(io, "Action ($(a.action_type), $(a.started_at))")
end

function get_all_actions(client::AbstractClient)
    uri = joinpath(ENDPOINT, "actions?per_page=200")
    body = get_data(client, uri)

    meta = body["meta"]
    links = body["links"]
    data = body["actions"]

    actions = Array{Action, 1}(meta["total"])

    for (i, action) in enumerate(data)
        actions[i] = Action(action)
    end

    actions
end

function get_action(client::AbstractClient, action_id::Integer)
    uri = joinpath(ENDPOINT, "actions", "$(action_id)")
    body = get_data(client, uri)

    data = body["action"]
    action = Action(data)
end

function get_action(client::AbstractClient, action::Action)
    get_action(client, action.name)
end
