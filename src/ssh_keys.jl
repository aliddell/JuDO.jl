struct SSHKey
    id::Integer
    fingerprint::String
    public_key::String
    name::String

    function SSHKey(data::Dict{String})
        new(
            data["id"],
            data["fingerprint"],
            data["public_key"],
            data["name"]
        )
    end
end

function show(io::IO, s::SSHKey)
    print(io, "SSHKey ($(s.name))")
end

function get_all_ssh_keys(client::AbstractClient)
    response = get_data(client, joinpath(ENDPOINT, "account", "keys?per_page=200"))

    if floor(response.status/100) == 2 # OK
        body = parse(String(response.body))
        meta = body["meta"]
        links = body["links"]
        data = body["ssh_keys"]

        ssh_keys = Array{SSHKey, 1}(UndefInitializer(), meta["total"])

        for (i, ssh_key) in enumerate(data)
            ssh_keys[i] = SSHKey(ssh_key)
        end
    else
        error("Received error $(response.status)")
    end

    ssh_keys
end

function get_ssh_key(client::AbstractClient, key_id::Union{Integer, String})
    response = get_data(client, joinpath(ENDPOINT, "account", "keys", "$key_id"))

    if floor(response.status/100) == 2 # OK
        body = parse(String(response.body))
        data = body["ssh_key"]

        ssh_key = SSHKey(data)
    else
        error("Received error $(response.status)")
    end
end

function get_ssh_key(client::AbstractClient, key::SSHKey)
    get_ssh_key(client, key.id)
end

function create_ssh_key(client::AbstractClient; kwargs...)
    body = Dict([String(k[1]) => k[2] for k in kwargs])

    if !haskey(body, "name")
        error("'name' is a required argument")
    end

    if !haskey(body, "public_key")
        error("'public_key' is a required argument")
    end

    response = post_data(client, joinpath(ENDPOINT, "account", "keys"), body)

    if floor(response.status/100) == 2 # OK
        body = parse(String(response.body))
        data = body["ssh_key"]

        ssh_key = SSHKey(data)
    else
        error("Received error $(response.status)")
    end
end

function update_ssh_key(client::AbstractClient, key_id::Union{Integer, String}; kwargs...)
    body = Dict([String(k[1]) => k[2] for k in kwargs])

    if !haskey(body, "name")
        error("'name' is a required argument")
    end

    uri = joinpath(ENDPOINT, "account", "keys", "$(key_id)")
    response = put_data(client, uri, body)

    if floor(response.status/100) == 2 # OK
        body = parse(String(response.body))
        data = body["ssh_key"]

        ssh_key = SSHKey(data)
    else
        error("Received error $(response.status)")
    end
end

function update_ssh_key(client::AbstractClient, key::SSHKey; kwargs...)
    update_ssh_key(client, key.id; kwargs...)
end

function delete_ssh_key(client::AbstractClient, key_id::Union{Integer, String})
    delete_data(client, joinpath(ENDPOINT, "account", "keys", "$(key_id)"))
end

function delete_ssh_key(client::AbstractClient, key::SSHKey)
    delete_ssh_key(client, key.id)
end
