struct Record
    id::Integer
    rtype::String
    name::String
    data::String
    priority::Nullable{Integer}
    port::Nullable{Integer}
    ttl::Integer
    weight::Nullable{Integer}
    flags::Nullable{Integer}
    tag::Nullable{String}

    function Record(data::Dict{String})
        new(
            data["id"],
            data["type"],
            data["name"],
            data["data"],
            data["priority"],
            data["port"],
            data["ttl"],
            data["weight"],
            data["flags"],
            data["tag"],
        )
    end
end

function show(io::IO, r::Record)
    print(io, "Record ($(r.rtype), $(r.name))")
end

function get_all_domain_records(client::AbstractClient, domain_name::String)
    uri = joinpath(ENDPOINT, "domains", domain_name, "records?per_page=200")
    response = get_data(client, uri)

    if floor(response.status/100) == 2 # OK
        body = JSON.parse(String(response.body))
        meta = body["meta"]
        links = body["links"]
        data = body["domain_records"]

        records = Array{Record, 1}(meta["total"])

        for (i, record) in enumerate(data)
            records[i] = Record(record)
        end
    else
        error("Received error $(response.status)")
    end

    records
end

function get_all_domain_records(client::AbstractClient, domain::Domain)
    get_all_domain_records(client, domain.name)
end

function get_domain_record(client::AbstractClient, domain_name::String,
                           record_id::Integer)
    response = get_data(client, joinpath(ENDPOINT, "domains", domain_name,
                        "records", "$record_id"))

    if floor(response.status/100) == 2 # OK
        body = JSON.parse(String(response.body))
        data = body["domain_record"]

        record = Record(data)
    else
        error("Received error $(response.status)")
    end
end

function create_domain_record(client::AbstractClient, domain_name::String,
                              record_type::String; kwargs...)
    post_body = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    post_body["type"] = record_type

    if record_type in ("A", "AAAA", "CAA", "CNAME", "MX", "TXT", "SRV", "NS")
        if !(record_type in ("MX", "NS") || "name" in keys(post_body))
            error("'name' is a required argument for type '$(record_type)'")
        end

        if !("data" in keys(post_body))
            error("'data' is a required argument for type '$(record_type)'")
        end
    end

    if record_type in ("SRV", "MX") && !("priority" in keys(post_body))
        error("'priority' is a required argument for type '$(record_type)'")
    end

    if record_type == "SRV"
        if !("port" in keys("post_body"))
            error("'port' is a required argument for type '$(record_type)'")
        end

        if !("weight" in keys(post_body))
            error("'weight' is a required argument for type '$(record_type)'")
        end
    end

    if record_type == "CAA"
        if !("flags" in keys(post_body))
            error("'flags' is a required argument for type '$(record_type)'")
        end

        if !("tag" in keys(post_body))
            error("'tag' is a required argument for type '$(record_type)'")
        end
    end

    if !("ttl" in keys(post_body))
        error("'ttl' is a required argument")
    end

    uri = joinpath(ENDPOINT, "domains", domain_name, "records")
    body = post_data(client, uri, post_body)

    data = body["domain_record"]
    record = Record(data)
end

function create_domain_record(client::AbstractClient, domain::Domain; kwargs...)
    create_domain_record(client, domain.name; kwargs...)
end

function get_domain_record(client::AbstractClient, domain::Domain,
                           record_id::Integer)
    get_domain_record(client, domain.name, record_id)
end

function get_domain_record(client::AbstractClient, domain_name::String,
                           record::Record)
    get_domain_record(client, domain_name, record.id)
end

function get_domain_record(client::AbstractClient, domain::Domain,
                           record::Record)
    get_domain_record(client, domain.name, record.id)
end

function update_domain_record(client::AbstractClient, domain_name::String,
                              record_id::Integer; kwargs...)
    body = Dict([String(k[1]) => k[2] for k in kwargs])

    uri = joinpath(ENDPOINT, "domains", domain_name, "records", "$(record_id)")
    response = put_data(client, uri, body)

    if floor(response.status/100) == 2 # OK
        body = JSON.parse(String(response.body))
        data = body["domain_record"]

        record = Record(data)
    else
        error("Received error $(response.status)")
    end
end

function update_domain_record(client::AbstractClient, domain::Domain, record_id::Integer; kwargs...)
    update_domain_record(client, domain.name, record_id; kwargs...)
end

function update_domain_record(client::AbstractClient, domain_name::String, record::Record; kwargs...)
    update_domain_record(client, domain_name, record.id; kwargs...)
end

function update_domain_record(client::AbstractClient, domain::Domain, record::Record; kwargs...)
    update_domain_record(client, domain.name, record.id; kwargs...)
end

function delete_domain_record(client::AbstractClient, domain_name::String, record_id::Integer)
    uri = joinpath(ENDPOINT, "domains", domain_name, "records", "$(record_id)")
    delete_data(client, uri)
end
