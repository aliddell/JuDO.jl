struct Certificate
    id::String
    name::String
    not_after::DateTime
    sha1_fingerprint::String
    created_at::DateTime

    function Certificate(data::Dict{String})
        data["not_after"] = DateTime(data["not_after"][1:end-1])
        data["created_at"] = DateTime(data["created_at"][1:end-1])

        new(
            data["id"],
            data["name"],
            data["not_after"],
            data["sha1_fingerprint"],
            data["created_at"]
        )
    end
end

function show(io::IO, c::Certificate)
    print(io, "Certificate ($(c.name))")
end

function get_all_certificates(client::AbstractClient)
    uri = joinpath(ENDPOINT, "certificates?per_page=200")
    body = get_data(client, uri)

    meta = body["meta"]
    links = body["links"]
    data = body["certificates"]

    certificates = Array{Certificate, 1}(UndefInitializer(), meta["total"])

    for (i, certificate) in enumerate(data)
        certificates[i] = Certificate(certificate)
    end

    certificates
end

function get_certificate(client::AbstractClient, certificate_id::String)
    uri = joinpath(ENDPOINT, "certificates", "$(certificate_id)")
    body = get_data(client, uri)

    data = body["certificate"]
    certificate = Certificate(data)
end

function get_certificate(client::AbstractClient, certificate::Certificate)
    get_certificate(client, certificate.id)
end

function create_certificate(client::AbstractClient; kwargs...)
    post_body = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !("name" in keys(post_body))
        error("'name' is a required argument")
    end

    if !("private_key" in keys(post_body))
        error("'private_key' is a required argument")
    end

    if !("leaf_certificate" in keys(post_body))
        error("'leaf_certificate' is a required argument")
    end

    uri = joinpath(ENDPOINT, "certificates")
    body = post_data(client, uri, post_body)

    data = body["certificate"]
    certificate = Certificate(data)
end

function delete_certificate(client::AbstractClient, certificate_id::String)
    uri = joinpath(ENDPOINT, "certificates", certificate_id)
    delete_data(client, uri)
end

function delete_certificate(client::AbstractClient, certificate::Certificate)
    delete_certificate(client, certificate.id)
end
