ENDPOINT = "https://api.digitalocean.com/v2/"
MAXOBJECTS = 200 # maximum number of objects one can request

abstract type AbstractClient end

mutable struct Client <: AbstractClient
    token::String
    ratelimit::Integer
    remainingrequests::Integer
    ratelimitreset::DateTime

    function Client(token::String)
        new(token, -1, -1, now())
    end
end

function show(io::IO, c::Client)
    print(io, "Client ($(c.token[1:8]))")
end

function handleresponse!(client::Client, response::HTTP.Response)
    headers = Dict(response.headers)
    client.ratelimit = parse(headers["Ratelimit-Limit"])
    client.remainingrequests = parse(headers["Ratelimit-Remaining"])
    client.ratelimitreset = unix2datetime(parse(headers["Ratelimit-Reset"]))

    if floor(response.status/100) == 2
        parse(String(response.body))
    else
        error("Received error $(response.status)")
    end
end

function getdata!(client::Client, uri::String)
    headers = Dict("Content-Type" => "application/json",
                   "Authorization" => "Bearer $(client.token)")
    response = 0

    try
        response = HTTP.get(uri, headers=headers)
    catch er
        error("Received error $(er.status)")
    end

    data = handleresponse!(client, response)

    # get the only key which is neither meta or links
    pkey = pop!(setdiff(keys(data), ["meta", "links"]))
    payload = data[pkey]

    if haskey(data, "links") && haskey(data["links"], "pages") &&
        haskey(data["links"]["pages"], "next")
        payload = [payload; getdata!(client, data["links"]["pages"]["next"])]
    end

    payload
end

function postdata!(client::Client, uri::String, body::Dict{String})
    headers = Dict("Content-Type" => "application/json",
                   "Authorization" => "Bearer $(client.token)")
    body = json(body)
    response = 0

    try
        response = HTTP.post(uri, headers=headers, body=body)
    catch er
        error("Received error $(er.status)")
    end

    data = handleresponse!(client, response)

    # data should have only one key
    pop!(data).second
end

function putdata!(client::Client, uri::String, body::Dict{String})
    headers = Dict("Content-Type" => "application/json",
                   "Authorization" => "Bearer $(client.token)")
    body = json(body)
    response = 0

    try
        response = HTTP.put(uri, headers=headers, body=body)
    catch er
        error("Received error $(er.status)")
    end

    data = handleresponse!(client, response)

    # data should have only one key
    pop!(data).second
end

function deletedata!(client::Client, uri::String)
    headers = Dict("Content-Type" => "application/json",
                   "Authorization" => "Bearer $(client.token)")
    response = 0

    try
       response = HTTP.delete(uri, headers=headers)
    catch er
       error("Received error $(er.status)")
    end

    handleresponse!(client, response)
    return true
end
