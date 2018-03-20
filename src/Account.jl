struct Account
    droplet_limit::Integer
    floating_ip_limit::Integer
    email::String
    uuid::String
    email_verified::Bool
    status::String
    status_message::String

    function Account(data::Dict{String, Any})
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

function show(io::IO, a::Account)
    print(io, "Account ($(a.email))")
end

function get_account(manager::Manager)
    response = get_data(manager, joinpath(ENDPOINT, "account"))

    if response.status == 200 # OK
        body = JSON.parse(String(response.body))
        data = body["account"]

        account = Account(data)
    else
        error("Received error $(response.status)")
    end
end
