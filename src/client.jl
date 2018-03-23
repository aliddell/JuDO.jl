ENDPOINT = "https://api.digitalocean.com/v2/"

abstract type AbstractClient end

mutable struct Client <: AbstractClient
    token::String
    ratelimit_limit::Integer
    ratelimit_remaining::Integer
    ratelimit_reset::Dates.DateTime

    function Client(token::String)
        new(token, -1, -1, now())
    end
end

function show(io::IO, c::Client)
    print(io, "Client ($(c.token[1:8]))")
end

function handle_response(client::Client, response::HTTP.Response)
    headers = Dict(response.headers)
    client.ratelimit_limit = parse(headers["Ratelimit-Limit"])
    client.ratelimit_remaining = parse(headers["Ratelimit-Remaining"])
    client.ratelimit_reset = Dates.unix2datetime(parse(headers["Ratelimit-Reset"]))

    if floor(response.status/100) == 2
        JSON.parse(String(response.body))
    else
        error("Received error $(response.status)")
    end
end

function get_data(client::Client, uri::String)
    headers = Dict("Content-Type" => "application/json",
                   "Authorization" => "Bearer $(client.token)")
    response = 0

    try
        response = HTTP.get(uri, headers=headers)
    catch er
        error("Received error $(er.status)")
    end

    handle_response(client, response)
end

function post_data(client::Client, uri::String, body::Dict{String})
    headers = Dict("Content-Type" => "application/json",
                   "Authorization" => "Bearer $(client.token)")
    body = JSON.json(body)
    response = 0

    try
        response = HTTP.post(uri, headers=headers, body=body)
    catch er
        error("Received error $(er.status)")
    end

    handle_response(client, response)
end

function put_data(client::Client, uri::String, body::Dict{String})
    headers = Dict("Content-Type" => "application/json",
                   "Authorization" => "Bearer $(client.token)")
    body = JSON.json(body)
    response = 0

    try
        response = HTTP.put(uri, headers=headers, body=body)
    catch er
        error("Received error $(er.status)")
    end

    handle_response(client, response)
end

function delete_data(client::Client, uri::String)
    headers = Dict("Content-Type" => "application/json",
                   "Authorization" => "Bearer $(client.token)")
    response = 0

    try
       response = HTTP.delete(uri, headers=headers)
    catch er
       error("Received error $(er.status)")
    end

    handle_response(client, response)
    return true
end
