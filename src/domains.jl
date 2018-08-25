struct Domain
    name::String
    ttl::Integer
    zonefile::Union{Nothing, String}

    function Domain(data::Dict{String})
        new(
            data["name"],
            data["ttl"],
            data["zone_file"]
        )
    end
end

function show(io::IO, d::Domain)
    print(io, "Domain ($(d.name))")
end

# List all domains
function getalldomains!(client::AbstractClient)
    uri = joinpath(ENDPOINT, "domains?per_page=$MAXOBJECTS")
    getalldata!(client, uri, Domain)
end

# Retrieve an existing domain
function getdomain!(client::AbstractClient, domain_name::String)
    uri = joinpath(ENDPOINT, "domains", domain_name)
    Domain(getdata!(client, uri))
end

function getdomain!(client::AbstractClient, domain::Domain)
    getdomain!(client, domain.name)
end

# Create a new domain
function createdomain!(client::AbstractClient; name::String, ip_address::String, kwargs...)
    postbody = Dict{String, Any}("name" => name, "ip_address" => ip_address)
    merge!(postbody, Dict{String, Any}([String(k[1]) => k[2] for k in kwargs]))

    uri = joinpath(ENDPOINT, "domains")
    Domain(postdata!(client, uri, postbody))
end

# Delete a domain
function deletedomain!(client::AbstractClient, domain_name::String)
    uri = joinpath(ENDPOINT, "domains", domain_name)
    deletedata!(client, uri)
end

function deletedomain!(client::AbstractClient, domain::Domain)
    deletedomain!(client, domain.name)
end
