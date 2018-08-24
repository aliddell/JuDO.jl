using JuDO
using Test
using DotEnv

import Dates: DateTime
import JuDO: getdata!, postdata!, putdata!, deletedata!, ENDPOINT, MAXOBJECTS
import JSON: parse

DotEnv.config()

DATADIR = joinpath(dirname(abspath(@__FILE__)), "data")

struct TestClient <: AbstractClient
    token::String
end

function getdata!(client::TestClient, uri::String)
    uri = replace(uri, ENDPOINT => "")
    # strip off query string
    idx = findfirst(isequal('?'), uri)
    if idx != nothing
        uri = uri[1:idx-1]
    end

    path = joinpath(DATADIR, uri, "get.json")
    data = open(path, "r") do io
        parse(read(io, String))
    end

    # get the only key which is neither meta or links
    pkey = pop!(setdiff(keys(data), ["meta", "links"]))
    data[pkey]
end

function postdata!(client::TestClient, uri::String, body::Dict{String})
    if endswith(uri, "actions")
        path = joinpath(DATADIR, replace(uri, ENDPOINT => ""),
                        "$(body["type"]).json")
    else
        path = joinpath(DATADIR, replace(uri, ENDPOINT => ""), "post.json")
    end
    data = open(path, "r") do io
        parse(read(io, String))
    end

    # data should have only one key
    pop!(data).second
end

function putdata!(client::TestClient, uri::String, body::Dict{String})
    path = joinpath(DATADIR, uri, "put.json")
    data = open(path, "r") do io
        parse(read(io, String))
    end

    # data should have only one key
    pop!(data).second
end

function deletedata!(client::TestClient, uri::String)
    true
end

testclient = TestClient("fake token")

# account tests
include("testaccount.jl")
# action tests
include("testactions.jl")
# certificate tests
include("testcertificates.jl")
# domain tests
include("testdomains.jl")
# volume tests
include("testvolumes.jl")

# real client test
if haskey(ENV, "DOTOKEN")
    client = Client(ENV["DOTOKEN"])
end
