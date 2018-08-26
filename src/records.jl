mutable struct Record
    id::Integer
    recordtype::String
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
    print(io, "Record ($(r.recordtype), $(r.name))")
end

# List all domain records
function getalldomainrecords!(client::AbstractClient, domainname::String)
    uri = joinpath(ENDPOINT, "domains", domainname, "records")
    getalldata!(client, uri, Record)
end

function getalldomainrecords!(client::AbstractClient, domain::Domain)
    getalldomainrecords!(client, domain.name)
end

# Retrieve an existing domain record
function getdomainrecord!(client::AbstractClient, domainname::String, record_id::Integer)
    uri = joinpath(ENDPOINT, "domains", domainname, "records", "$record_id")
    Record(getdata!(client, uri))
end

function getdomainrecord!(client::AbstractClient, domain::Domain, record_id::Integer)
    getdomainrecord!(client, domain.name, record_id)
end

# Create a new domain record
function createdomainrecord!(client::AbstractClient, domainname::String,
                             recordtype::String; kwargs...)
    postbody = Dict{String, Any}("type" => recordtype)
    merge!(postbody, Dict{String, Any}([String(k[1]) => k[2] for k in kwargs]))

    if recordtype in ("A", "AAAA", "CAA", "CNAME", "MX", "TXT", "SRV", "NS")
        if !(recordtype in ("MX", "NS") || haskey(postbody, "name"))
            error("'name' is a required argument for type '$(recordtype)'")
        end
        if !haskey(postbody, "data")
            error("'data' is a required argument for type '$(recordtype)'")
        end
    end
    if recordtype in ("SRV", "MX") && !haskey(postbody, "priority")
        error("'priority' is a required argument for type '$(recordtype)'")
    end
    if recordtype == "SRV"
        if !haskey("postbody", "port")
            error("'port' is a required argument for type '$(recordtype)'")
        end
        if !haskey(postbody, "weight")
            error("'weight' is a required argument for type '$(recordtype)'")
        end
    end
    if recordtype == "CAA"
        if !haskey(postbody, "flags")
            error("'flags' is a required argument for type '$(recordtype)'")
        end
        if !haskey(postbody, "tag")
            error("'tag' is a required argument for type '$(recordtype)'")
        end
    end

    uri = joinpath(ENDPOINT, "domains", domainname, "records")
    Record(postdata!(client, uri, postbody))
end

function createdomainrecord!(client::AbstractClient, domain::Domain,
                             recordtype::String; kwargs...)
    createdomainrecord!(client, domain.name, recordtype; kwargs...)
end

# Update a Domain Record
function updatedomainrecord!(client::AbstractClient, domainname::String,
                             record_id::Integer; kwargs...)
    putbody = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    uri = joinpath(ENDPOINT, "domains", domainname, "records", "$(record_id)")
    Record(putdata!(client, uri, putbody))
end

function updatedomainrecord!(client::AbstractClient, domain::Domain, record_id::Integer; kwargs...)
    updatedomainrecord!(client, domain.name, record_id; kwargs...)
end

function updatedomainrecord!(client::AbstractClient, domainname::String, record::Record; kwargs...)
    data = updatedomainrecord!(client, domainname, record.id; kwargs...)
    for k in kwargs
        if k[1] in fieldnames(Domain)
            setfield!(record, Symbol(k[1]), k[2])
        end
    end
    data
end

function updatedomainrecord!(client::AbstractClient, domain::Domain, record::Record; kwargs...)
    updatedomainrecord!(client, domain.name, record; kwargs...)
end

# Delete a Domain Record
function deletedomainrecord!(client::AbstractClient, domainname::String, record_id::Integer)
    uri = joinpath(ENDPOINT, "domains", domainname, "records", "$(record_id)")
    deletedata!(client, uri)
end

function deletedomainrecord!(client::AbstractClient, domainname::String, record::Record)
    deletedomainrecord!(client, domainname, record.id)
end
