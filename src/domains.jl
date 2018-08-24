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

function getalldomains!(client::AbstractClient)
    uri = joinpath(ENDPOINT, "domains?per_page=$MAXOBJECTS")
    data = getdata!(client, uri)
    domains = Array{Domain, 1}(UndefInitializer(), length(data))

    for (i, domain) in enumerate(data)
        domains[i] = Domain(domain)
    end

    domains
end

function getdomain!(client::AbstractClient, domain_name::String)
    uri = joinpath(ENDPOINT, "domains", domain_name)
    Domain(getdata!(client, uri))
end

function getdomain!(client::AbstractClient, domain::Domain)
    getdomain!(client, domain.name)
end

function createdomain!(client::AbstractClient; kwargs...)
    postbody = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(postbody, "name")
        error("'name' is a required argument")
    end

    if !haskey(postbody, "ip_address")
        error("'ip_address' is a required argument")
    end

    uri = joinpath(ENDPOINT, "domains")
    Domain(postdata!(client, uri, postbody))
end

function deletedomain!(client::AbstractClient, domain_name::String)
    uri = joinpath(ENDPOINT, "domains", domain_name)
    deletedata!(client, uri)
end

function deletedomain!(client::AbstractClient, domain::Domain)
    deletedomain!(client, domain.name)
end
