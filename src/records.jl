struct Record
    id::Integer
    rtype::String
    name::String
    data::String
    priority::Union{Nothing, Integer}
    port::Union{Nothing, Integer}
    ttl::Integer
    weight::Union{Nothing, Integer}
    flags::Union{Nothing, Integer}
    tag::Union{Nothing, String}

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

function getalldomainrecords!(client::AbstractClient, domain_name::String)
    uri = joinpath(ENDPOINT, "domains", domain_name, "records")
    response = getdata!(client, uri)

    if floor(response.status/100) == 2 # OK
        body = parse(String(response.body))
        meta = body["meta"]
        links = body["links"]
        data = body["domain_records"]

        records = Array{Record, 1}(UndefInitializer(), meta["total"])

        for (i, record) in enumerate(data)
            records[i] = Record(record)
        end
    else
        error("Received error $(response.status)")
    end

    records
end

function getalldomainrecords!(client::AbstractClient, domain::Domain)
    getalldomainrecords!(client, domain.name)
end

function getdomainrecord!(client::AbstractClient, domain_name::String,
                           record_id::Integer)
    response = getdata!(client, joinpath(ENDPOINT, "domains", domain_name,
                        "records", "$record_id"))

    if floor(response.status/100) == 2 # OK
        body = parse(String(response.body))
        data = body["domain_record"]

        record = Record(data)
    else
        error("Received error $(response.status)")
    end
end

function createdomainrecord!(client::AbstractClient, domain_name::String,
                              record_type::String; kwargs...)
    postbody = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    postbody["type"] = record_type

    if record_type in ("A", "AAAA", "CAA", "CNAME", "MX", "TXT", "SRV", "NS")
        if !(record_type in ("MX", "NS") || haskey(postbody, "name"))
            error("'name' is a required argument for type '$(record_type)'")
        end

        if !haskey(postbody, "data")
            error("'data' is a required argument for type '$(record_type)'")
        end
    end

    if record_type in ("SRV", "MX") && !haskey(postbody, "priority")
        error("'priority' is a required argument for type '$(record_type)'")
    end

    if record_type == "SRV"
        if !haskey("postbody", "port")
            error("'port' is a required argument for type '$(record_type)'")
        end

        if !haskey(postbody, "weight")
            error("'weight' is a required argument for type '$(record_type)'")
        end
    end

    if record_type == "CAA"
        if !haskey(postbody, "flags")
            error("'flags' is a required argument for type '$(record_type)'")
        end

        if !haskey(postbody, "tag")
            error("'tag' is a required argument for type '$(record_type)'")
        end
    end

    if !haskey(postbody, "ttl")
        error("'ttl' is a required argument")
    end

    uri = joinpath(ENDPOINT, "domains", domain_name, "records")
    body = postdata!(client, uri, postbody)

    data = body["domain_record"]
    record = Record(data)
end

function createdomainrecord!(client::AbstractClient, domain::Domain; kwargs...)
    createdomainrecord!(client, domain.name; kwargs...)
end

function getdomainrecord!(client::AbstractClient, domain::Domain,
                           record_id::Integer)
    getdomainrecord!(client, domain.name, record_id)
end

function getdomainrecord!(client::AbstractClient, domain_name::String,
                           record::Record)
    getdomainrecord!(client, domain_name, record.id)
end

function getdomainrecord!(client::AbstractClient, domain::Domain,
                           record::Record)
    getdomainrecord!(client, domain.name, record.id)
end

function update_domain_record(client::AbstractClient, domain_name::String,
                              record_id::Integer; kwargs...)
    putbody = Dict([String(k[1]) => k[2] for k in kwargs])

    uri = joinpath(ENDPOINT, "domains", domain_name, "records", "$(record_id)")
    response = putdata!(client, uri, body)

    if floor(response.status/100) == 2 # OK
        body = parse(String(response.body))
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

function deletedomainrecord!(client::AbstractClient, domain_name::String, record_id::Integer)
    uri = joinpath(ENDPOINT, "domains", domain_name, "records", "$(record_id)")
    deletedata!(client, uri)
end
