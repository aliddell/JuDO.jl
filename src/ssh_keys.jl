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

function getallsshkeys!(client::AbstractClient)
    response = getdata!(client, joinpath(ENDPOINT, "account", "keys"))

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

function getsshkey!(client::AbstractClient, key_id::Union{Integer, String})
    response = getdata!(client, joinpath(ENDPOINT, "account", "keys", "$key_id"))

    if floor(response.status/100) == 2 # OK
        body = parse(String(response.body))
        data = body["ssh_key"]

        ssh_key = SSHKey(data)
    else
        error("Received error $(response.status)")
    end
end

function getsshkey!(client::AbstractClient, key::SSHKey)
    getsshkey!(client, key.id)
end

function createsshkey!(client::AbstractClient; kwargs...)
    body = Dict([String(k[1]) => k[2] for k in kwargs])

    if !haskey(body, "name")
        error("'name' is a required argument")
    end

    if !haskey(body, "public_key")
        error("'public_key' is a required argument")
    end

    response = postdata!(client, joinpath(ENDPOINT, "account", "keys"), body)

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
    response = putdata!(client, uri, body)

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

function deletesshkey!(client::AbstractClient, key_id::Union{Integer, String})
    deletedata!(client, joinpath(ENDPOINT, "account", "keys", "$(key_id)"))
end

function deletesshkey!(client::AbstractClient, key::SSHKey)
    deletesshkey!(client, key.id)
end
