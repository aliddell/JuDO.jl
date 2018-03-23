using JuDO
using Base.Test

import JuDO: get_data, post_data, put_data, delete_data, ENDPOINT

DATA_DIR = joinpath(dirname(abspath(@__FILE__)), "data")

struct TestClient <: AbstractClient
    token::String
end

function get_data(client::TestClient, uri::String)
    uri = replace(replace(uri, ENDPOINT, ""), "?per_page=200", "")
    path = joinpath(DATA_DIR, uri, "get.json")
    JSON.parse(readstring(path))
end

function post_data(client::TestClient, uri::String, body::Dict{String})
    if endswith(uri, "actions")
        path = joinpath(DATA_DIR, replace(uri, ENDPOINT, ""),
                        "$(body["type"]).json")
    else
        path = joinpath(DATA_DIR, replace(uri, ENDPOINT, ""), "post.json")
    end
    JSON.parse(readstring(path))
end

function put_data(client::TestClient, uri::String, body::Dict{String})
    path = joinpath(DATA_DIR, uri, "put.json")
    JSON.parse(readstring(path))
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
if "dotok" in keys(ENV)
    client = Client(ENV["dotok"])
end
