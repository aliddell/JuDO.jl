struct Domain
    name::String
    ttl::Integer
    zone_file::Nullable{String}

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

function get_all_domains(client::AbstractClient)
    uri = joinpath(ENDPOINT, "domains?per_page=200")
    body = get_data(client, uri)

    meta = body["meta"]
    links = body["links"]

    data = body["domains"]
    domains = Array{Domain, 1}(meta["total"])

    for (i, domain) in enumerate(data)
        domains[i] = Domain(domain)
    end

    domains
end

function get_domain(client::AbstractClient, domain_name::String)
    uri = joinpath(ENDPOINT, "domains", domain_name)
    body = get_data(client, uri)

    data = body["domain"]
    domain = Domain(data)
end

function get_domain(client::AbstractClient, domain::Domain)
    get_domain(client, domain.name)
end

function create_domain(client::AbstractClient; kwargs...)
    post_body = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !("name" in keys(post_body))
        error("'name' is a required argument")
    end

    if !("ip_address" in keys(post_body))
        error("'ip_address' is a required argument")
    end

    uri = joinpath(ENDPOINT, "domains")
    body = post_data(client, uri, post_body)

    data = body["domain"]
    domain = Domain(data)
end

function delete_domain(client::AbstractClient, domain_name::String)
    uri = joinpath(ENDPOINT, "domains", domain_name)
    delete_data(client, uri)
end

function delete_domain(client::AbstractClient, domain::Domain)
    delete_domain(client, domain.name)
end
