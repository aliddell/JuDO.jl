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

function get_all_ssh_keys(manager::Manager)
    response = get_data(manager, joinpath(ENDPOINT, "account", "keys?per_page=200"))

    if response.status == 200 # OK
        body = JSON.parse(String(response.body))
        meta = body["meta"]
        links = body["links"]
        data = body["ssh_keys"]

        ssh_keys = Array{SSHKey, 1}(meta["total"])

        for (i, ssh_key) in enumerate(data)
            ssh_keys[i] = SSHKey(ssh_key)
        end
    else
        error("Received error $(response.status)")
    end

    ssh_keys
end

function get_ssh_key(manager::Manager, key_id::Union{Integer, String})
    response = get_data(manager, joinpath(ENDPOINT, "account", "keys", "$key_id"))

    if response.status == 200 # OK
        body = JSON.parse(String(response.body))
        data = body["ssh_key"]

        ssh_key = SSHKey(data)
    else
        error("Received error $(response.status)")
    end
end

function get_ssh_key(manager::Manager, key::SSHKey)
    get_ssh_key(manager, key.id)
end

function create_ssh_key(manager::Manager; kwargs...)
    body = Dict([String(k[1]) => k[2] for k in kwargs])

    if !("name" in keys(body))
        error("'name' is a required argument")
    end

    if !("public_key" in keys(body))
        error("'public_key' is a required argument")
    end

    response = post_data(manager, joinpath(ENDPOINT, "account", "keys"), body)

    if response.status == 201 # OK
        body = JSON.parse(String(response.body))
        data = body["ssh_key"]

        ssh_key = SSHKey(data)
    else
        error("Received error $(response.status)")
    end
end

function update_ssh_key(manager::Manager, key_id::Union{Integer, String}; kwargs...)
    #/v2/account/keys/$SSH_KEY_ID or /v2/account/keys/$SSH_KEY_FINGERPRINT
    body = Dict([String(k[1]) => k[2] for k in kwargs])

    if !("name" in keys(body))
        error("'name' is a required argument")
    end

    response = put_data(manager, joinpath(ENDPOINT, "account", "keys", "$(key_id)"), body)

    if response.status == 200 # OK
        body = JSON.parse(String(response.body))
        data = body["ssh_key"]

        ssh_key = SSHKey(data)
    else
        error("Received error $(response.status)")
    end
end

function update_ssh_key(manager::Manager, key::SSHKey; kwargs...)
    update_ssh_key(manager, key.id; kwargs...)
end

function delete_ssh_key(manager::Manager, key_id::Union{Integer, String})
    delete_data(manager, joinpath(ENDPOINT, "account", "keys", "$(key_id)"))
end

function delete_ssh_key(manager::Manager, key::SSHKey)
    delete_ssh_key(manager, key.id)
end
