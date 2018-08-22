struct Account
    droplet_limit::Integer
    floating_ip_limit::Integer
    email::String
    uuid::String
    email_verified::Bool
    status::String
    status_message::String

    function Account(data::Dict{String})
        new(
            data["droplet_limit"],
            data["floating_ip_limit"],
            data["email"],
            data["uuid"],
            data["email_verified"],
            data["status"],
            data["status_message"]
        )
    end
end

function ==(a::Account, b::Account)
    for fn in fieldnames(Account)
        if getproperty(a, fn) != getproperty(b, fn)
            return false
        end
    end

    return true
end

function show(io::IO, a::Account)
    print(io, "Account ($(a.email))")
end

function get_account(client::AbstractClient)
    uri = joinpath(ENDPOINT, "account")
    body = get_data(client, uri)

    data = body["account"]
    account = Account(data)
end
