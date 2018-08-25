struct Certificate
    id::String
    name::String
    notafter::DateTime
    sha1fingerprint::String
    created_at::DateTime
    dnsnames::Array{String, 1}
    state::String
    certificatetype::String

    function Certificate(data::Dict{String})
        data["not_after"] = DateTime(data["not_after"][1:end-1])
        data["created_at"] = DateTime(data["created_at"][1:end-1])

        new(
            data["id"],
            data["name"],
            data["not_after"],
            data["sha1_fingerprint"],
            data["created_at"],
            data["dns_names"],
            data["state"],
            data["type"]
        )
    end
end

function show(io::IO, c::Certificate)
    print(io, "Certificate ($(c.name))")
end

# List all certificates
function getallcertificates!(client::AbstractClient)
    uri = joinpath(ENDPOINT, "certificates?per_page=$MAXOBJECTS")
    getalldata!(client, uri, Certificate)
end

# Retrieve an existing certificate
function getcertificate!(client::AbstractClient, certificateid::String)
    uri = joinpath(ENDPOINT, "certificates", "$(certificateid)")
    Certificate(getdata!(client, uri))
end

function getcertificate!(client::AbstractClient, certificate::Certificate)
    getcertificate!(client, certificate.id)
end

function createcertificate!(client::AbstractClient; name::String, private_key::String,
                            leaf_certificate::String, kwargs...)
    postbody = Dict{String, Any}("name" => name, "private_key" => private_key,
                                 "leaf_certificate" => leaf_certificate)
    merge!(postbody, Dict{String, Any}([String(k[1]) => k[2] for k in kwargs]))

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
