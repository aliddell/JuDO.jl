struct Domain
    name::String
    ttl::Integer
    zone_file::String

    function Domain(data::Dict{String, Any})
        new(
            data["name"],
            data["ttl"],
            data["zone_file"],
        )
    end
end

function show(io::IO, d::Domain)
    print(io, "Domain ($(d.name))")
end

function get_all_domains(manager::Manager)
    response = get_data(manager, joinpath(ENDPOINT, "domains?per_page=200"))

    if response.status == 200 # OK
        body = JSON.parse(String(response.body))
        meta = body["meta"]
        links = body["links"]
        data = body["domains"]

        domains = Array{Domain, 1}(meta["total"])

        for (i, domain) in enumerate(data)
            domains[i] = Domain(domain)
        end
    else
        error("Received error $(response.status)")
    end

    domains
end

function get_domain(manager::Manager, domain_name::String)
    response = get_data(manager, joinpath(ENDPOINT, "domains", domain_name))

    if response.status == 200 # OK
        body = JSON.parse(String(response.body))
        data = body["domain"]

        domain = Domain(data)
    else
        error("Received error $(response.status)")
    end
end

function get_domain(manager::Manager, domain::Domain)
    get_domain(manager, domain.name)
end

function create_domain(manager::Manager, name::String, ip_address::String)
    body = Dict("name" => name, "ip_address" => ip_address)
    response = post_data(manager, joinpath(ENDPOINT, "domains"), body)

    if response.status == 202 # OK
        body = JSON.parse(String(response.body))
        data = body["domain"]

        domain = Domain(data)
    else
        error("Received error $(response.status)")
    end
end

function delete_domain(manager::Manager, domain_name::String)
    delete_data(manager, joinpath(ENDPOINT, "domains", domain_name))
end

function delete_domain(manager::Manager, domain::Domain)
    delete_domain(manager, domain.name)
end
