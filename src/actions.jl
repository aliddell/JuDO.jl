struct Action
    id::Integer
    status::String
    action_type::String
    started_at::DateTime
    completed_at::Union{Nothing, DateTime}
    resource_id::Union{Nothing, Integer}
    resource_type::String
    region::Union{Nothing, Region}
    region_slug::Union{Nothing, String}

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
    print(io, "Action ($(a.action_type), $(a.started_at))")
end

function get_all_actions(client::AbstractClient)
    uri = joinpath(ENDPOINT, "actions?per_page=$MAXOBJECTS")
    body = get_data(client, uri)

    meta = body["meta"]
    links = body["links"]
    data = body["actions"]

    total_actions = meta["total"]
    actions = Array{Action, 1}(UndefInitializer(), total_actions)

    for (i, action) in enumerate(data)
        actions[i] = Action(action)
    end

    # get the rest of the actions in as few requests as possible
    page = 1
    while haskey(links["pages"], "next")
        uri = links["pages"]["next"]
        body = get_data(client, uri)

        links = body["links"]
        data = body["actions"]

        for (i, action) in enumerate(data)
            actions[page*MAXOBJECTS + i] = Action(action)
        end

        page += 1
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
