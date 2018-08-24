struct Certificate
    id::String
    name::String
    notafter::DateTime
    sha1fingerprint::String
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

function getallcertificates!(client::AbstractClient)
    uri = joinpath(ENDPOINT, "certificates?per_page=$MAXOBJECTS")
    data = getdata!(client, uri)
    certificates = Array{Certificate, 1}(UndefInitializer(), length(data))

    for (i, certificate) in enumerate(data)
        certificates[i] = Certificate(certificate)
    end

    certificates
end

function getcertificate!(client::AbstractClient, certificateid::String)
    uri = joinpath(ENDPOINT, "certificates", "$(certificateid)")
    Certificate(getdata!(client, uri))
end

function getcertificate!(client::AbstractClient, certificate::Certificate)
    getcertificate!(client, certificate.id)
end

function createcertificate!(client::AbstractClient; kwargs...)
    postbody = Dict{String, Any}([String(k[1]) => k[2] for k in kwargs])

    if !haskey(postbody, "name")
        error("'name' is a required argument")
    end

    if !haskey(postbody, "private_key")
        error("'private_key' is a required argument")
    end

    if !haskey(postbody, "leaf_certificate")
        error("'leaf_certificate' is a required argument")
    end

    uri = joinpath(ENDPOINT, "certificates")
    Certificate(postdata!(client, uri, postbody))
end

function deletecertificate!(client::AbstractClient, certificateid::String)
    uri = joinpath(ENDPOINT, "certificates", certificateid)
    deletedata!(client, uri)
end

function deletecertificate!(client::AbstractClient, certificate::Certificate)
    deletecertificate!(client, certificate.id)
end
