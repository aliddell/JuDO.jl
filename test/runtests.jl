using JuDO
using Test

import Dates: DateTime
import JuDO: get_data, post_data, put_data, delete_data, ENDPOINT, MAXOBJECTS
import JSON: parse

DATA_DIR = joinpath(dirname(abspath(@__FILE__)), "data")

struct TestClient <: AbstractClient
    token::String
end

function get_data(client::TestClient, uri::String)
    uri = replace(uri, ENDPOINT => "")
    # strip off query string
    idx = findfirst(isequal('?'), uri)
    if idx != nothing
        uri = uri[1:idx-1]
    end

    path = joinpath(DATA_DIR, uri, "get.json")
    data = open(path, "r") do io
        parse(read(io, String))
    end

    # remove "next" to prevent infinite loops
    if haskey(data, "links") && haskey(data["links"], "pages")
        delete!(data["links"]["pages"], "next")
    end

    data
end

function post_data(client::TestClient, uri::String, body::Dict{String})
    if endswith(uri, "actions")
        path = joinpath(DATA_DIR, replace(uri, ENDPOINT => ""),
                        "$(body["type"]).json")
    else
        path = joinpath(DATA_DIR, replace(uri, ENDPOINT => ""), "post.json")
    end
    open(path, "r") do io
        parse(read(io, String))
    end
end

function put_data(client::TestClient, uri::String, body::Dict{String})
    path = joinpath(DATA_DIR, uri, "put.json")
    open(path, "r") do io
        parse(read(io, String))
    end
end

function delete_data(client::TestClient, uri::String)
    true
end

test_client = TestClient("fake token")

# account tests
include("test_account.jl")

# action tests
include("test_actions.jl")

# certificate tests
include("test_certificates.jl")

# domain tests
include("test_domains.jl")

# volume tests
include("test_volumes.jl")

# real client test
if haskey(ENV, "dotok")
    client = Client(ENV["dotok"])
end
