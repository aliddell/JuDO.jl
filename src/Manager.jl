import HTTP
import JSON

ENDPOINT = "https://api.digitalocean.com/v2/"

mutable struct Manager
    token::String
    ratelimit_limit::Integer
    ratelimit_remaining::Integer
    ratelimit_reset::DateTime
    # constructor
    Manager(token::String) = begin
        new(token, -1, -1, now())
    end
end

function show(io::IO, m::Manager)
    print(io, "Manager ($(m.token[1:8]))")
end

function get_data(manager::Manager, url::String)
    headers = Dict("Content-Type" => "application/json",
                   "Authorization" => "Bearer $(manager.token)")
    response = 0

    try
        response = HTTP.get(url, headers=headers)
    catch er
        error("Received error $(er.status)")
    end

    headers = response.headers
    manager.ratelimit_limit = parse(headers["Ratelimit-Limit"])
    manager.ratelimit_remaining = parse(headers["Ratelimit-Remaining"])
    manager.ratelimit_reset = Dates.unix2datetime(parse(headers["Ratelimit-Reset"]))

    response
end

function post_data(manager::Manager, url::String, body::Dict{String})
    headers = Dict("Content-Type" => "application/json",
                   "Authorization" => "Bearer $(manager.token)")
    body = JSON.json(body)
    response = 0

    try
        response = HTTP.post(url, headers=headers, body=body)
    catch er
        error("Received error $(er.status)")
    end

    headers = response.headers
    manager.ratelimit_limit = parse(headers["Ratelimit-Limit"])
    manager.ratelimit_remaining = parse(headers["Ratelimit-Remaining"])
    manager.ratelimit_reset = Dates.unix2datetime(parse(headers["Ratelimit-Reset"]))

    response
end

function put_data(manager::Manager, url::String, body::Dict{String})
    headers = Dict("Content-Type" => "application/json",
                   "Authorization" => "Bearer $(manager.token)")
    body = JSON.json(body)
    response = 0

    try
        response = HTTP.put(url, headers=headers, body=body)
    catch er
        error("Received error $(er.status)")
    end

    headers = response.headers
    manager.ratelimit_limit = parse(headers["Ratelimit-Limit"])
    manager.ratelimit_remaining = parse(headers["Ratelimit-Remaining"])
    manager.ratelimit_reset = Dates.unix2datetime(parse(headers["Ratelimit-Reset"]))

    response
end

function delete_data(manager::Manager, url::String)
    headers = Dict("Content-Type" => "application/json",
                   "Authorization" => "Bearer $(manager.token)")
    response = 0

    try
       response = HTTP.delete(url, headers=headers)
    catch er
       error("Received error $(er.status)")
    end

    if response.status != 204
        error("Received error $(response.status)")
    end

    headers = response.headers
    manager.ratelimit_limit = parse(headers["Ratelimit-Limit"])
    manager.ratelimit_remaining = parse(headers["Ratelimit-Remaining"])
    manager.ratelimit_reset = Dates.unix2datetime(parse(headers["Ratelimit-Reset"]))

    return
end
